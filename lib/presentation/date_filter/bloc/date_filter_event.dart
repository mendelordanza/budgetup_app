part of 'date_filter_bloc.dart';

@immutable
abstract class DateFilterEvent {}

class SelectDate extends DateFilterEvent {
  final DateFilterType dateFilterType;
  final DateTime selectedDate;

  SelectDate(this.dateFilterType, this.selectedDate);
}
