import 'package:budgetup_app/helper/colors.dart';
import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:budgetup_app/injection_container.dart';
import 'package:budgetup_app/presentation/recurring/bloc/recurring_bill_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../helper/date_helper.dart';
import 'bloc/recurring_date_filter_bloc.dart';

class RecurringDateBottomSheet extends HookWidget {
  RecurringDateBottomSheet({Key? key}) : super(key: key);

  final types = [
    DateSelection(
      "Monthly",
      DateFilterType.monthly,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final sharedPrefs = getIt<SharedPrefs>();

    final _selectedFilterType = useState<DateFilterType>(
        enumFromString(sharedPrefs.getRecurringSelectedDateFilterType()));
    final _selectedDate = useState<DateTime>(
      sharedPrefs.getRecurringSelectedDate().isNotEmpty
          ? DateTime.parse(sharedPrefs.getRecurringSelectedDate())
          : DateTime.now(),
    );

    return Container(
      padding: EdgeInsets.all(16.0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      ),
      child: Column(
        children: [
          _buildHandle(context),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: types.map((element) {
                    return _tab(
                      context,
                      label: element.label,
                      isSelected: _selectedFilterType.value == element.type,
                      onSelect: () {
                        _selectedFilterType.value = element.type;
                        context.read<RecurringDateFilterBloc>().add(
                            RecurringSelectDate(
                                element.type, _selectedDate.value));
                        context
                            .read<RecurringBillBloc>()
                            .add(LoadRecurringBills(_selectedDate.value));
                      },
                    );
                  }).toList(),
                ),
                // ElevatedButton(
                //   onPressed: () {
                //     _selectedDate.value = DateTime.now();
                //     context
                //         .read<DateFilterBloc>()
                //         .add(SelectDate(DateTime.now()));
                //   },
                //   child: Text("Today"),
                // ),
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
                    context.read<RecurringDateFilterBloc>().add(
                        RecurringSelectDate(
                            _selectedFilterType.value, selectedDay));
                    context.read<RecurringBillBloc>().add(LoadRecurringBills(selectedDay));
                  },
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarBuilders: CalendarBuilders(
                    dowBuilder: (context, day) {
                      if (day.weekday == DateTime.sunday) {
                        final text = DateFormat.E().format(day);

                        return Center(
                          child: Text(
                            text,
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
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
          color: isSelected ? secondaryColor : Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
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