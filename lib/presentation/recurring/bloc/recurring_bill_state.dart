part of 'recurring_bill_bloc.dart';

@immutable
abstract class RecurringBillState {}

class RecurringBillInitial extends RecurringBillState {}

class RecurringBillsLoaded extends RecurringBillState {
  final List<RecurringBill> recurringBills;
  final List<RecurringBill> paidRecurringBills;

  RecurringBillsLoaded({
    required this.paidRecurringBills,
    required this.recurringBills,
  });
}
