import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:budgetup_app/domain/recurring_bill.dart';
import 'package:meta/meta.dart';

import '../../../data/recurring_bills_repository.dart';
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
        add(LoadRecurringBills(state.selectedDate));
      } else if (state is UnmarkAsPaid) {
        add(LoadRecurringBills(state.selectedDate));
      }
    });

    on<LoadRecurringBills>((event, emit) async {
      final recurringBills = await recurringBillsRepo.getRecurringBills();
      final paidRecurringBills =
          await recurringBillsRepo.getPaidRecurringBills(event.selectedDate);

      final convertedRecurringBills = recurringBills.map((bill) {
        final convertedAmount = sharedPrefs.getCurrencyCode() == "USD"
            ? (bill.amount ?? 0.00)
            : (bill.amount ?? 0.00) * sharedPrefs.getCurrencyRate();
        return bill.copy(amount: convertedAmount);
      }).toList();

      final convertedPaidRecurringBills = paidRecurringBills.map((bill) {
        final convertedAmount = sharedPrefs.getCurrencyCode() == "USD"
            ? (bill.amount ?? 0.00)
            : (bill.amount ?? 0.00) * sharedPrefs.getCurrencyRate();
        return bill.copy(amount: convertedAmount);
      }).toList();

      emit(RecurringBillsLoaded(
        total: getPaidRecurringBillTotal(convertedPaidRecurringBills),
        recurringBills: convertedRecurringBills,
      ));
    });
    on<ConvertRecurringBill>((event, emit) async {
      if (state is RecurringBillsLoaded) {
        final recurringBills = await recurringBillsRepo.getRecurringBills();
        final paidRecurringBills =
            await recurringBillsRepo.getPaidRecurringBills(
                DateTime.parse(sharedPrefs.getRecurringSelectedDate()));

        final convertedRecurringBills = recurringBills.map((bill) {
          final convertedAmount = event.currencyCode == "USD"
              ? (bill.amount ?? 0.00)
              : (bill.amount ?? 0.00) * event.currencyRate;
          return bill.copy(amount: convertedAmount);
        }).toList();

        final convertedPaidRecurringBills = paidRecurringBills.map((bill) {
          final convertedAmount = event.currencyCode == "USD"
              ? (bill.amount ?? 0.00)
              : (bill.amount ?? 0.00) * event.currencyRate;
          return bill.copy(amount: convertedAmount);
        }).toList();

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
}
