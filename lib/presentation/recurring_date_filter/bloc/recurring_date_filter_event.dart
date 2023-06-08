part of 'recurring_date_filter_bloc.dart';

@immutable
abstract class RecurringDateFilterEvent {}

class RecurringSelectDate extends RecurringDateFilterEvent {
  final DateFilterType dateFilterType;
  final DateTime selectedDate;

  RecurringSelectDate(this.dateFilterType, this.selectedDate);
}
