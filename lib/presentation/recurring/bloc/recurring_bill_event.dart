part of 'recurring_bill_bloc.dart';

@immutable
abstract class RecurringBillEvent {}

class LoadRecurringBills extends RecurringBillEvent {
  final DateTime selectedDate;

  LoadRecurringBills(this.selectedDate);
}

class LoadPaidRecurringBills extends RecurringBillEvent {}

class ConvertRecurringBill extends RecurringBillEvent {
  final String currencyCode;
  final double currencyRate;

  ConvertRecurringBill({
    required this.currencyCode,
    required this.currencyRate,
  });
}
