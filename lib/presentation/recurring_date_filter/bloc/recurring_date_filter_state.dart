part of 'recurring_date_filter_bloc.dart';

@immutable
abstract class RecurringDateFilterState {}

class RecurringDateFilterInitial extends RecurringDateFilterState {}

class RecurringDateFilterSelected extends RecurringDateFilterState {
  final DateTime selectedDate;
  final DateFilterType dateFilterType;

  RecurringDateFilterSelected(this.dateFilterType, this.selectedDate);
}
