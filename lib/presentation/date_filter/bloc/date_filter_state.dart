part of 'date_filter_bloc.dart';

@immutable
abstract class DateFilterState {}

class DateFilterInitial extends DateFilterState {}

class DateFilterSelected extends DateFilterState {
  final DateTime selectedDate;
  final DateFilterType dateFilterType;

  DateFilterSelected(this.dateFilterType, this.selectedDate);
}
