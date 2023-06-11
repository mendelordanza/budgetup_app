part of 'recurring_bill_bloc.dart';

@immutable
abstract class RecurringBillEvent {}

class LoadRecurringBills extends RecurringBillEvent {
  final DateTime selectedDate;

  LoadRecurringBills(this.selectedDate);
}

class LoadPaidRecurringBills extends RecurringBillEvent {}
