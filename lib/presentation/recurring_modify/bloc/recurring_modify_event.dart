part of 'recurring_modify_bloc.dart';

@immutable
abstract class RecurringModifyEvent {}

class AddRecurringBill extends RecurringModifyEvent {
  final DateTime selectedDate;
  final RecurringBill recurringBill;

  AddRecurringBill({required this.selectedDate, required this.recurringBill});
}

class EditRecurringBill extends RecurringModifyEvent {
  final DateTime selectedDate;
  final RecurringBill recurringBill;

  EditRecurringBill({required this.selectedDate, required this.recurringBill});
}

class RemoveRecurringBill extends RecurringModifyEvent {
  final DateTime selectedDate;
  final RecurringBill recurringBill;

  RemoveRecurringBill(
      {required this.selectedDate, required this.recurringBill});
}

class ArchiveRecurringBill extends RecurringModifyEvent {
  final DateTime selectedDate;
  final RecurringBill recurringBill;

  ArchiveRecurringBill(
      {required this.selectedDate, required this.recurringBill});
}

class AddRecurringBillTxn extends RecurringModifyEvent {
  final DateTime selectedDate;
  final RecurringBill recurringBill;
  final RecurringBillTxn recurringBillTxn;

  AddRecurringBillTxn({
    required this.selectedDate,
    required this.recurringBill,
    required this.recurringBillTxn,
  });
}

class RemoveRecurringBillTxn extends RecurringModifyEvent {
  final DateTime selectedDate;
  final RecurringBill recurringBill;
  final RecurringBillTxn recurringBillTxn;

  RemoveRecurringBillTxn({
    required this.selectedDate,
    required this.recurringBill,
    required this.recurringBillTxn,
  });
}
