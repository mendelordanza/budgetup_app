import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../helper/date_helper.dart';
import '../../../helper/shared_prefs.dart';

part 'date_filter_event.dart';

part 'date_filter_state.dart';

class DateFilterBloc extends Bloc<DateFilterEvent, DateFilterState> {
  final SharedPrefs sharedPrefs;

  DateFilterBloc({required this.sharedPrefs}) : super(DateFilterInitial()) {
    on<SelectDate>((event, emit) {
      sharedPrefs.setSelectedDateFilterType(event.dateFilterType);
      sharedPrefs.setExpenseSelectedDate(event.selectedDate.toIso8601String());
      emit(DateFilterSelected(event.dateFilterType, event.selectedDate));
    });
  }
}
