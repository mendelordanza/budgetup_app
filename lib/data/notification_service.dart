import 'package:budgetup_app/helper/date_helper.dart';
import 'package:budgetup_app/presentation/recurring_modify/add_recurring_bill_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  initNotification() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('budgetup_icon');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification:
                (int id, String? tile, String? body, String? payload) {});

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (notificationResponse) {});
  }

  notificationDetails() {
    return NotificationDetails(
        android: AndroidNotificationDetails(
          'recurring_bill',
          "Recurring Bill Reminder",
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails());
  }

  showNotif() async {
    await flutterLocalNotificationsPlugin.show(
        0, "SAMPLE", "SAMPLE", notificationDetails());
  }

  scheduleNotification(
    int id,
    String title,
    String body,
    String date,
    String interval,
  ) async {
    tz.initializeTimeZones();
    final localTimezone = await FlutterTimezone.getLocalTimezone();

    DateTimeComponents dateTimeComponents;
    if (interval == RecurringBillInterval.monthly.name) {
      dateTimeComponents = DateTimeComponents.dayOfMonthAndTime;
    } else if (interval == RecurringBillInterval.weekly.name) {
      dateTimeComponents = DateTimeComponents.dayOfWeekAndTime;
    } else {
      dateTimeComponents = DateTimeComponents.dateAndTime;
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstance(interval, date, localTimezone),
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: dateTimeComponents,
    );
  }

  tz.TZDateTime _nextInstance(
    String interval,
    String date,
    String localTimezone,
  ) {
    final recurringBillInterval = RecurringBillInterval.values
        .firstWhere((element) => element.name == interval);
    final convertedDate = DateTime.parse(date);
    final location = tz.getLocation(localTimezone);
    tz.setLocalLocation(location);
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    switch (recurringBillInterval) {
      case RecurringBillInterval.monthly:
        tz.TZDateTime scheduledDate = tz.TZDateTime.from(
            DateTime(
              now.year,
              convertedDate.month,
              convertedDate.day,
              convertedDate.hour,
              convertedDate.minute,
            ),
            location);
        if (scheduledDate.isBefore(now)) {
          scheduledDate = tz.TZDateTime.from(
              DateTime(
                now.year,
                now.month + 1,
                convertedDate.day,
                convertedDate.hour,
                convertedDate.minute,
              ),
              location);
        }
        print("SCHED: ${scheduledDate}");
        return scheduledDate;
      case RecurringBillInterval.yearly:
        tz.TZDateTime scheduledDate = tz.TZDateTime.from(
            DateTime(
              now.year,
              convertedDate.month,
              convertedDate.day,
              convertedDate.hour,
              convertedDate.minute,
            ),
            location);
        if (scheduledDate.isBefore(now)) {
          scheduledDate = tz.TZDateTime.from(
              DateTime(
                now.year + 1,
                convertedDate.month,
                convertedDate.day,
                convertedDate.hour,
                convertedDate.minute,
              ),
              location);
        }
        return scheduledDate;
      case RecurringBillInterval.weekly:
        tz.TZDateTime scheduledDate = tz.TZDateTime.from(
            DateTime(
              now.year,
              convertedDate.month,
              convertedDate.day,
              convertedDate.hour,
              convertedDate.minute,
            ),
            location);
        if (scheduledDate.isBefore(now)) {
          scheduledDate = tz.TZDateTime.from(
              DateTime(
                now.year,
                now.month,
                now.day + 7,
                convertedDate.hour,
                convertedDate.minute,
              ),
              location);
        }
        return scheduledDate;
      // case RecurringBillInterval.quarterly:
      //   int quarter = ((convertedDate.month - 1) / 3).ceil() + 1;
      //
      //   tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      //       DateTime(
      //         now.year,
      //         getMonthFromQuarter(convertedDate, quarter),
      //         convertedDate.day,
      //         convertedDate.hour,
      //         convertedDate.minute,
      //       ),
      //       location);
      //   if (scheduledDate.isBefore(now)) {
      //     scheduledDate = tz.TZDateTime.from(
      //         DateTime(
      //           now.year,
      //           getMonthFromQuarter(convertedDate, quarter) + 3,
      //           convertedDate.day,
      //           convertedDate.hour,
      //           convertedDate.minute,
      //         ),
      //         location);
      //   }
      //   return scheduledDate;
    }
  }

  getMonthFromQuarter(DateTime convertedDate, int quarter) {
    var month = convertedDate.month;
    switch (quarter) {
      case 1:
        month = 3;
        break;
      case 2:
        month = 6;
        break;
      case 3:
        month = 9;
        break;
      case 4:
        month = 12;
        break;
    }
    return month;
  }

  cancelNotif(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}

// @pragma(
//     'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     final notificationService = getIt<NotificationService>();
//     final localTimezone = await FlutterTimezone.getLocalTimezone();
//     await notificationService.flutterLocalNotificationsPlugin.zonedSchedule(
//       0,
//       inputData?["title"],
//       inputData?["body"],
//       notificationService._nextInstance(
//           inputData?["interval"], inputData?["date"], localTimezone),
//       notificationService.notificationDetails(),
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
//     );
//     return Future.value(true);
//   });
// }
