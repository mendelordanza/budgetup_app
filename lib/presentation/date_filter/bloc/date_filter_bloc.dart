
import 'package:bloc/bloc.dart';
import 'package:budgetup_app/presentation/date_filter/date_bottom_sheet.dart';
import 'package:budgetup_app/presentation/expenses/bloc/expense_bloc.dart';
import 'package:budgetup_app/presentation/recurring/bloc/recurring_bill_bloc.dart';
import 'package:meta/meta.dart';

import '../../../helper/shared_prefs.dart';

part 'date_filter_event.dart';

part 'date_filter_state.dart';

DateFilterType enumFromString(String value) {
  return DateFilterType.values
      .firstWhere((e) => e.toString().split('.').last == value);
}

class DateFilterBloc extends Bloc<DateFilterEvent, DateFilterState> {
  final ExpenseBloc expenseBloc;
  final RecurringBillBloc recurringBillBloc;
  final SharedPrefs sharedPrefs;

  DateFilterBloc({
    required this.sharedPrefs,
    required this.expenseBloc,
    required this.recurringBillBloc,
  }) : super(DateFilterInitial()) {
    on<SelectDateFilterType>((event, emit) {
      sharedPrefs.setSelectedDateFilterType(event.dateFilterType);
    });
    on<SelectDate>((event, emit) {
      sharedPrefs.setSelectedDate(event.selectedDate.toIso8601String());

      expenseBloc.add(LoadExpenseCategories(event.selectedDate));
      recurringBillBloc.add(LoadRecurringBills());
    });
  }
}
