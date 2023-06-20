import 'package:budgetup_app/helper/colors.dart';
import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:budgetup_app/injection_container.dart';
import 'package:budgetup_app/presentation/expense_date_filter/bloc/date_filter_bloc.dart';
import 'package:budgetup_app/presentation/expenses/bloc/expense_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../helper/date_helper.dart';

class ExpenseDateBottomSheet extends HookWidget {

  ExpenseDateBottomSheet({Key? key}) : super(key: key);

  final types = [
    DateSelection(
      "Daily",
      DateFilterType.daily,
    ),
    DateSelection(
      "Weekly",
      DateFilterType.weekly,
    ),
    DateSelection(
      "Monthly",
      DateFilterType.monthly,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final sharedPrefs = getIt<SharedPrefs>();

    final _selectedFilterType = useState<DateFilterType>(
        dateFilterTypeFromString(sharedPrefs.getSelectedDateFilterType()));
    final _selectedDate = useState<DateTime>(
      sharedPrefs.getExpenseSelectedDate().isNotEmpty
          ? DateTime.parse(sharedPrefs.getExpenseSelectedDate())
          : DateTime.now(),
    );
    final _currentYear = useState(DateTime.now().year);

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(
          16.0,
        ),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        ),
        child: BlocBuilder<ExpenseDateFilterBloc, ExpenseDateFilterState>(
          builder: (context, state) {
            return Column(
              children: [
                _buildHandle(context),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: types.map((element) {
                    return _tab(
                      context,
                      label: element.label,
                      isSelected: _selectedFilterType.value == element.type,
                      onSelect: () {
                        _selectedFilterType.value = element.type;
                        context.read<ExpenseDateFilterBloc>().add(
                            ExpenseSelectDate(
                                element.type, _selectedDate.value));
                        context.read<ExpenseBloc>().add(
                              LoadExpenseCategories(
                                dateFilterType: element.type,
                                selectedDate: _selectedDate.value,
                              ),
                            );
                      },
                    );
                  }).toList(),
                ),
                if (_selectedFilterType.value != DateFilterType.monthly)
                  TableCalendar(
                    firstDay: DateTime.utc(2010, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: _selectedDate.value,
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                    ),
                    availableGestures: AvailableGestures.all,
                    locale: "en_US",
                    selectedDayPredicate: (day) {
                      return isSameDay(day, _selectedDate.value);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      _selectedDate.value = selectedDay;
                      context.read<ExpenseDateFilterBloc>().add(
                          ExpenseSelectDate(
                              _selectedFilterType.value, selectedDay));
                      context.read<ExpenseBloc>().add(
                            LoadExpenseCategories(
                              dateFilterType: _selectedFilterType.value,
                              selectedDate: selectedDay,
                            ),
                          );
                    },
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, date) {
                        final text = DateFormat.d().format(day);

                        return Center(
                          child: Text(
                            text,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        );
                      },
                      dowBuilder: (context, day) {
                        if (day.weekday == DateTime.sunday) {
                          final text = DateFormat.E().format(day);

                          return Center(
                            child: Text(
                              text,
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        } else {
                          return Center(
                            child: Text(
                              DateFormat.E().format(day),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  )
                else
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                _currentYear.value = _currentYear.value - 1;
                                context
                                    .read<ExpenseDateFilterBloc>()
                                    .add(ExpenseSelectDate(
                                        _selectedFilterType.value,
                                        DateTime(
                                          _currentYear.value,
                                          _selectedDate.value.month,
                                          _selectedDate.value.day,
                                        )));
                                context.read<ExpenseBloc>().add(
                                      LoadExpenseCategories(
                                        dateFilterType:
                                            _selectedFilterType.value,
                                        selectedDate: DateTime(
                                          _currentYear.value,
                                          _selectedDate.value.month,
                                          _selectedDate.value.day,
                                        ),
                                      ),
                                    );
                              },
                              icon: SvgPicture.asset(
                                "assets/icons/ic_arrow_left.svg",
                              ),
                            ),
                            Text("${_currentYear.value}"),
                            IconButton(
                              onPressed: () {
                                if (_currentYear.value != DateTime.now().year) {
                                  _currentYear.value = _currentYear.value + 1;
                                  context
                                      .read<ExpenseDateFilterBloc>()
                                      .add(ExpenseSelectDate(
                                          _selectedFilterType.value,
                                          DateTime(
                                            _currentYear.value,
                                            _selectedDate.value.month,
                                            _selectedDate.value.day,
                                          )));
                                  context.read<ExpenseBloc>().add(
                                        LoadExpenseCategories(
                                          dateFilterType:
                                              _selectedFilterType.value,
                                          selectedDate: DateTime(
                                            _currentYear.value,
                                            _selectedDate.value.month,
                                            _selectedDate.value.day,
                                          ),
                                        ),
                                      );
                                }
                              },
                              icon: SvgPicture.asset(
                                "assets/icons/ic_arrow_right.svg",
                              ),
                            ),
                          ],
                        ),
                      ),
                      Wrap(
                        children:
                            generateMonthList(_currentYear.value).map((date) {
                          return GestureDetector(
                            onTap: () {
                              _selectedDate.value = date;
                              context.read<ExpenseDateFilterBloc>().add(
                                  ExpenseSelectDate(
                                      _selectedFilterType.value, date));
                              context.read<ExpenseBloc>().add(
                                    LoadExpenseCategories(
                                      dateFilterType: _selectedFilterType.value,
                                      selectedDate: date,
                                    ),
                                  );
                            },
                            child: _monthItem(context,
                                date: formatDate(date, "MMMM"),
                                isSelected:
                                    _selectedDate.value.month == date.month),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Done"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _monthItem(
    BuildContext context, {
    required String date,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 8.0,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          date,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _tab(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required Function() onSelect,
  }) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 5.0,
          horizontal: 16.0,
        ),
        decoration: BoxDecoration(
          color: isSelected ? secondaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    final theme = Theme.of(context);

    return FractionallySizedBox(
      widthFactor: 0.25,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          height: 5.0,
          decoration: BoxDecoration(
            color: theme.dividerColor,
            borderRadius: const BorderRadius.all(Radius.circular(2.5)),
          ),
        ),
      ),
    );
  }
}
