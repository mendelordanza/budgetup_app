import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:budgetup_app/domain/recurring_bill.dart';
import 'package:budgetup_app/helper/date_helper.dart';
import 'package:budgetup_app/presentation/recurring_modify/add_recurring_bill_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:meta/meta.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../data/recurring_bills_repository.dart';
import '../../../helper/constant.dart';
import '../../../helper/shared_prefs.dart';
import '../../recurring_modify/bloc/recurring_modify_bloc.dart';
import '../../settings/currency/bloc/convert_currency_cubit.dart';

part 'recurring_bill_event.dart';

part 'recurring_bill_state.dart';

class RecurringBillBloc extends Bloc<RecurringBillEvent, RecurringBillState> {
  final SharedPrefs sharedPrefs;
  final RecurringBillsRepository recurringBillsRepo;
  final RecurringModifyBloc recurringModifyBloc;
  final ConvertCurrencyCubit convertCurrencyCubit;
  StreamSubscription? _recurringSubscription;
  StreamSubscription? _currencySubscription;

  RecurringBillBloc({
    required this.recurringBillsRepo,
    required this.recurringModifyBloc,
    required this.convertCurrencyCubit,
    required this.sharedPrefs,
  }) : super(RecurringBillInitial()) {
    _currencySubscription = convertCurrencyCubit.stream.listen((state) {
      if (state is ConvertedCurrencyLoaded) {
        add(ConvertRecurringBill(
            currencyCode: state.currencyCode,
            currencyRate: state.currencyRate));
      }
    });

    _recurringSubscription = recurringModifyBloc.stream.listen((state) {
      add(LoadRecurringBills());
    });

    on<LoadRecurringBills>((event, emit) async {
      final selectedDate = DateTime.parse(sharedPrefs.getSelectedDate());
      final selectedDateFilterType =
          dateFilterTypeFromString(sharedPrefs.getSelectedDateFilterType());
      final allRecurringBills = await getRecurringBillList(
          currencyCode: sharedPrefs.getCurrencyCode(),
          currencyRate: sharedPrefs.getCurrencyRate(),
          selectedDate: selectedDate);

      final paidRecurringBills = await getPaidRecurringBillList(
          currencyCode: sharedPrefs.getCurrencyCode(),
          currencyRate: sharedPrefs.getCurrencyRate(),
          selectedDateFilterType: selectedDateFilterType,
          selectedDate: selectedDate);

      //GET UPCOMING BILLS
      _setupWidget(recurringBills: allRecurringBills);

      emit(RecurringBillsLoaded(
        total: getPaidRecurringBillTotal(paidRecurringBills),
        recurringBills: allRecurringBills,
      ));
    });
    on<ConvertRecurringBill>((event, emit) async {
      if (state is RecurringBillsLoaded) {
        final allRecurringBills = await getRecurringBillList(
            currencyCode: event.currencyCode,
            currencyRate: event.currencyRate,
            selectedDate: DateTime.parse(sharedPrefs.getSelectedDate()));

        final paidRecurringBills = await getPaidRecurringBillList(
            currencyCode: event.currencyCode,
            currencyRate: event.currencyRate,
            selectedDateFilterType: dateFilterTypeFromString(
                sharedPrefs.getSelectedDateFilterType()),
            selectedDate: DateTime.parse(sharedPrefs.getSelectedDate()));

        //GET UPCOMING BILLS
        _setupWidget(recurringBills: allRecurringBills);

        emit(RecurringBillsLoaded(
          total: getPaidRecurringBillTotal(paidRecurringBills),
          recurringBills: allRecurringBills,
        ));
      }
    });
  }

  Future<List<RecurringBill>> getRecurringBillList({
    required String currencyCode,
    required double currencyRate,
    required DateTime selectedDate,
  }) async {
    final recurringBills = await recurringBillsRepo.getRecurringBills();

    //Filter out monthly and yearly
    final filteredRecurringBills = recurringBills.where((bill) {
      final notArchived = bill.archivedDate == null ||
          bill.archivedDate != null &&
              (selectedDate.month < bill.archivedDate!.month &&
                  selectedDate.year == bill.archivedDate!.year);

      return notArchived;
    }).toList();

    filteredRecurringBills.sort((a, b) {
      return a.reminderDate!.compareTo(b.reminderDate!);
    });

    return filteredRecurringBills;
  }

  getPaidRecurringBillList({
    required String currencyCode,
    required double currencyRate,
    required DateFilterType selectedDateFilterType,
    required DateTime selectedDate,
  }) async {
    final paidRecurringBills = await recurringBillsRepo.getPaidRecurringBills(
      selectedDateFilterType,
      selectedDate,
    );

    //Filter out monthly and yearly
    final filteredRecurringBills = paidRecurringBills.where((bill) {
      final notArchived = bill.archivedDate == null ||
          bill.archivedDate != null &&
              (selectedDate.month < bill.archivedDate!.month &&
                  selectedDate.year == bill.archivedDate!.year);

      return notArchived;
    }).toList();

    filteredRecurringBills
        .sort((a, b) => a.reminderDate!.compareTo(b.reminderDate!));

    return filteredRecurringBills;
  }

  getPaidRecurringBillTotal(List<RecurringBill> paidRecurringBills) {
    var total = 0.0;
    paidRecurringBills.forEach((element) {
      total += element.amount ?? 0.0;
    });
    return total;
  }

  @override
  Future<void> close() {
    _recurringSubscription?.cancel();
    _currencySubscription?.cancel();
    return super.close();
  }

  _setupWidget({
    required List<RecurringBill> recurringBills,
  }) async {
    try {
      List<RecurringBill> data = [];
      recurringBills.forEach((bill) {
        if (bill.interval == RecurringBillInterval.monthly.name) {
          final billReminderDate = DateTime(DateTime.now().year,
              DateTime.now().month, bill.reminderDate!.day);
          if (billReminderDate.isBefore(DateTime.now())) {
            data.add(bill.copy(
                reminderDate: DateTime(DateTime.now().year,
                    DateTime.now().month + 1, bill.reminderDate!.day)));
          } else {
            data.add(bill.copy(
                reminderDate: DateTime(DateTime.now().year,
                    DateTime.now().month, bill.reminderDate!.day)));
          }
        } else if (bill.interval == RecurringBillInterval.weekly.name) {
          final billReminderDate = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            bill.reminderDate!.day,
          );
          if (billReminderDate.isBefore(DateTime.now())) {
            data.add(bill.copy(
                reminderDate: DateTime(DateTime.now().year,
                    DateTime.now().month, DateTime.now().day + 7)));
          } else {
            data.add(
              bill.copy(
                reminderDate: DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  bill.reminderDate!.day,
                ),
              ),
            );
          }
        } else if (bill.interval == RecurringBillInterval.yearly.name) {
          final billReminderDate = DateTime(DateTime.now().year,
              bill.reminderDate!.month, bill.reminderDate!.day);

          if (billReminderDate.isBefore(DateTime.now())) {
            data.add(bill.copy(
                reminderDate: DateTime(DateTime.now().year + 1,
                    bill.reminderDate!.month, bill.reminderDate!.day)));
          } else {
            data.add(bill.copy(
                reminderDate: DateTime(DateTime.now().year,
                    bill.reminderDate!.month, bill.reminderDate!.day)));
          }
        }
      });
      data.sort((a, b) => a.reminderDate!.compareTo(b.reminderDate!));

      final jsonData = data.take(2).map((e) => e.toJson()).toList();
      final upcomingBills = jsonEncode(jsonData);

      final customerInfo = await Purchases.getCustomerInfo();
      final isSubscribed = customerInfo.entitlements.active[entitlementId] !=
              null &&
          customerInfo.entitlements.active[entitlementId]!.isSandbox == false;
      print("BILLS SEND!: $upcomingBills");
      Future.wait([
        HomeWidget.saveWidgetData<String>('upcomingBills', upcomingBills),
        HomeWidget.saveWidgetData<bool>('isSubscribed', isSubscribed),
      ]);
    } on PlatformException catch (exception) {
      debugPrint('Error Sending Data. $exception');
    }

    try {
      HomeWidget.updateWidget(
          name: 'UpcomingBillsWidgetProvider', iOSName: 'BillsWidget');
    } on PlatformException catch (exception) {
      debugPrint('Error Updating Widget. $exception');
    }
  }
}
