import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:budgetup_app/domain/recurring_bill.dart';
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
      if (state is RecurringBillAdded) {
        add(LoadRecurringBills(state.selectedDate));
      } else if (state is RecurringBillEdited) {
        add(LoadRecurringBills(state.selectedDate));
      } else if (state is RecurringBillRemoved) {
        add(LoadRecurringBills(state.selectedDate));
      } else if (state is MarkAsPaid) {
        final currentSelectedDate =
            DateTime.parse(sharedPrefs.getRecurringSelectedDate());
        add(LoadRecurringBills(currentSelectedDate));
      } else if (state is UnmarkAsPaid) {
        final currentSelectedDate =
            DateTime.parse(sharedPrefs.getRecurringSelectedDate());
        add(LoadRecurringBills(currentSelectedDate));
      }
    });

    on<LoadRecurringBills>((event, emit) async {
      final recurringBills = await recurringBillsRepo.getRecurringBills();

      //Filter out monthly and yearly
      final filteredRecurringBills = recurringBills.where((bill) {
        return bill.interval == RecurringBillInterval.monthly.name ||
            (bill.interval == RecurringBillInterval.yearly.name &&
                bill.reminderDate!.month == event.selectedDate.month);
      }).toList();

      final paidRecurringBills =
          await recurringBillsRepo.getPaidRecurringBills(event.selectedDate);

      final convertedRecurringBills = filteredRecurringBills.map((bill) {
        final convertedAmount = sharedPrefs.getCurrencyCode() == "USD"
            ? (bill.amount ?? 0.00)
            : (bill.amount ?? 0.00) * sharedPrefs.getCurrencyRate();
        return bill.copy(amount: convertedAmount);
      }).toList();
      convertedRecurringBills
          .sort((a, b) => a.reminderDate!.compareTo(b.reminderDate!));

      final convertedPaidRecurringBills = paidRecurringBills.map((bill) {
        final convertedAmount = sharedPrefs.getCurrencyCode() == "USD"
            ? (bill.amount ?? 0.00)
            : (bill.amount ?? 0.00) * sharedPrefs.getCurrencyRate();
        return bill.copy(amount: convertedAmount);
      }).toList();
      convertedPaidRecurringBills
          .sort((a, b) => a.reminderDate!.compareTo(b.reminderDate!));

      //GET UPCOMING BILLS
      _setupWidget(recurringBills: convertedRecurringBills);

      emit(RecurringBillsLoaded(
        total: getPaidRecurringBillTotal(convertedPaidRecurringBills),
        recurringBills: convertedRecurringBills,
      ));
    });
    on<ConvertRecurringBill>((event, emit) async {
      if (state is RecurringBillsLoaded) {
        final recurringBills = await recurringBillsRepo.getRecurringBills();

        //Filter out monthly and yearly
        final filteredRecurringBills = recurringBills.where((bill) {
          return bill.interval == RecurringBillInterval.monthly.name ||
              (bill.interval == RecurringBillInterval.yearly.name &&
                  bill.reminderDate!.month ==
                      DateTime.parse(sharedPrefs.getRecurringSelectedDate())
                          .month);
        }).toList();

        final paidRecurringBills =
            await recurringBillsRepo.getPaidRecurringBills(
                DateTime.parse(sharedPrefs.getRecurringSelectedDate()));

        final convertedRecurringBills = filteredRecurringBills.map((bill) {
          final convertedAmount = event.currencyCode == "USD"
              ? (bill.amount ?? 0.00)
              : (bill.amount ?? 0.00) * event.currencyRate;
          return bill.copy(amount: convertedAmount);
        }).toList();
        convertedRecurringBills
            .sort((a, b) => a.reminderDate!.compareTo(b.reminderDate!));

        final convertedPaidRecurringBills = paidRecurringBills.map((bill) {
          final convertedAmount = event.currencyCode == "USD"
              ? (bill.amount ?? 0.00)
              : (bill.amount ?? 0.00) * event.currencyRate;
          return bill.copy(amount: convertedAmount);
        }).toList();
        convertedPaidRecurringBills
            .sort((a, b) => a.reminderDate!.compareTo(b.reminderDate!));

        //GET UPCOMING BILLS
        _setupWidget(recurringBills: convertedRecurringBills);

        emit(RecurringBillsLoaded(
          total: getPaidRecurringBillTotal(convertedPaidRecurringBills),
          recurringBills: convertedRecurringBills,
        ));
      }
    });
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
      final isSubscribed =
          customerInfo.entitlements.active[entitlementId] != null;
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
