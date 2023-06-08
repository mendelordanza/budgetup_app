import 'package:bloc/bloc.dart';
import 'package:budgetup_app/presentation/date_filter/date_bottom_sheet.dart';
import 'package:meta/meta.dart';

import '../../../helper/shared_prefs.dart';

part 'date_filter_event.dart';

part 'date_filter_state.dart';

DateFilterType enumFromString(String value) {
  return DateFilterType.values
      .firstWhere((e) => e.toString().split('.').last == value);
}

class DateFilterBloc extends Bloc<DateFilterEvent, DateFilterState> {
  final SharedPrefs sharedPrefs;

  DateFilterBloc({required this.sharedPrefs}) : super(DateFilterInitial()) {
    on<SelectDate>((event, emit) {
      sharedPrefs.setSelectedDateFilterType(event.dateFilterType);
      sharedPrefs.setSelectedDate(event.selectedDate.toIso8601String());
      emit(DateFilterSelected(event.dateFilterType, event.selectedDate));
    });
  }
}
