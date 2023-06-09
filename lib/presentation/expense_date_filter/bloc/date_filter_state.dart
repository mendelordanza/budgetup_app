part of 'date_filter_bloc.dart';

@immutable
abstract class ExpenseDateFilterState {}

class ExpenseDateFilterInitial extends ExpenseDateFilterState {}

class ExpenseDateFilterSelected extends ExpenseDateFilterState {
  final DateTime selectedDate;
  final DateFilterType dateFilterType;

  ExpenseDateFilterSelected(this.dateFilterType, this.selectedDate);
}
