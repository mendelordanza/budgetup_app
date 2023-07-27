import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../helper/date_helper.dart';
import '../../../helper/shared_prefs.dart';

part 'recurring_date_filter_event.dart';

part 'recurring_date_filter_state.dart';

class RecurringDateFilterBloc
    extends Bloc<RecurringDateFilterEvent, RecurringDateFilterState> {
  final SharedPrefs sharedPrefs;

  RecurringDateFilterBloc({required this.sharedPrefs})
      : super(RecurringDateFilterInitial()) {
    on<RecurringSelectDate>((event, emit) {
      sharedPrefs.setSelectedDateFilterType(event.dateFilterType);
      sharedPrefs
          .setSelectedDate(event.selectedDate.toIso8601String());
      emit(RecurringDateFilterSelected(
          event.dateFilterType, event.selectedDate));
    });
  }
}
