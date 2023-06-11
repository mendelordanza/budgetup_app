part of 'recurring_modify_bloc.dart';

@immutable
abstract class RecurringModifyState {}

class RecurringModifyInitial extends RecurringModifyState {}

class RecurringBillAdded extends RecurringModifyState {
  final DateTime selectedDate;

  RecurringBillAdded(this.selectedDate);
}

class RecurringBillEdited extends RecurringModifyState {
  final DateTime selectedDate;

  RecurringBillEdited(this.selectedDate);
}

class RecurringBillRemoved extends RecurringModifyState {
  final DateTime selectedDate;

  RecurringBillRemoved(this.selectedDate);
}

class MarkAsPaid extends RecurringModifyState {
  final DateTime selectedDate;

  MarkAsPaid(this.selectedDate);
}

class UnmarkAsPaid extends RecurringModifyState {
  final DateTime selectedDate;

  UnmarkAsPaid(this.selectedDate);
}
