part of 'date_filter_bloc.dart';

@immutable
abstract class ExpenseDateFilterEvent {}

class ExpenseSelectDate extends ExpenseDateFilterEvent {
  final DateFilterType dateFilterType;
  final DateTime selectedDate;

  ExpenseSelectDate(this.dateFilterType, this.selectedDate);
}
