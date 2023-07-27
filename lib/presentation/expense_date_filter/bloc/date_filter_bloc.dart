import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../helper/date_helper.dart';
import '../../../helper/shared_prefs.dart';

part 'date_filter_event.dart';

part 'date_filter_state.dart';

class ExpenseDateFilterBloc extends Bloc<ExpenseDateFilterEvent, ExpenseDateFilterState> {
  final SharedPrefs sharedPrefs;

  ExpenseDateFilterBloc({required this.sharedPrefs}) : super(ExpenseDateFilterInitial()) {
    on<ExpenseSelectDate>((event, emit) {
      sharedPrefs.setSelectedDateFilterType(event.dateFilterType);
      sharedPrefs.setSelectedDate(event.selectedDate.toIso8601String());
      emit(ExpenseDateFilterSelected(event.dateFilterType, event.selectedDate));
    });
  }
}
