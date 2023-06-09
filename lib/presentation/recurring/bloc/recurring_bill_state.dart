part of 'recurring_bill_bloc.dart';

@immutable
abstract class RecurringBillState {}

class RecurringBillInitial extends RecurringBillState {}

class RecurringBillsLoaded extends RecurringBillState {
  final double? total;
  final List<RecurringBill> recurringBills;

  RecurringBillsLoaded({
    this.total,
    required this.recurringBills,
  });
}
