part of 'recurring_bill_bloc.dart';

@immutable
abstract class RecurringBillEvent {}

class LoadRecurringBills extends RecurringBillEvent {}

class AddRecurringBill extends RecurringBillEvent {
  final RecurringBill recurringBill;

  AddRecurringBill({required this.recurringBill});
}

class EditRecurringBill extends RecurringBillEvent {
  final RecurringBill recurringBill;

  EditRecurringBill({required this.recurringBill});
}

class RemoveRecurringBill extends RecurringBillEvent {
  final RecurringBill recurringBill;

  RemoveRecurringBill({required this.recurringBill});
}

class AddRecurringBillTxn extends RecurringBillEvent {
  final RecurringBill recurringBill;
  final RecurringBillTxn recurringBillTxn;

  AddRecurringBillTxn({
    required this.recurringBill,
    required this.recurringBillTxn,
  });
}

class RemoveRecurringBillTxn extends RecurringBillEvent {
  final RecurringBill recurringBill;
  final RecurringBillTxn recurringBillTxn;

  RemoveRecurringBillTxn({
    required this.recurringBill,
    required this.recurringBillTxn,
  });
}
