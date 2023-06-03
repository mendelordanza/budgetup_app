part of 'date_filter_bloc.dart';

@immutable
abstract class DateFilterEvent {}

class SelectDateFilterType extends DateFilterEvent {
  final DateFilterType dateFilterType;

  SelectDateFilterType(this.dateFilterType);
}

class SelectDate extends DateFilterEvent {
  final DateTime selectedDate;

  SelectDate(this.selectedDate);
}
