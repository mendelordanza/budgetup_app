part of 'recurring_bill_bloc.dart';

@immutable
abstract class RecurringBillEvent {}

class LoadRecurringBills extends RecurringBillEvent {
  final DateTime selectedDate;

  LoadRecurringBills(this.selectedDate);
}

class LoadPaidRecurringBills extends RecurringBillEvent {}

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
  final DateTime selectedDate;
  final RecurringBill recurringBill;
  final RecurringBillTxn recurringBillTxn;

  AddRecurringBillTxn({
    required this.selectedDate,
    required this.recurringBill,
    required this.recurringBillTxn,
  });
}

class RemoveRecurringBillTxn extends RecurringBillEvent {
  final DateTime selectedDate;
  final RecurringBill recurringBill;
  final RecurringBillTxn recurringBillTxn;

  RemoveRecurringBillTxn({
    required this.selectedDate,
    required this.recurringBill,
    required this.recurringBillTxn,
  });
}
