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

    // Workmanager().initialize(
    //     callbackDispatcher, // The top level function, aka callbackDispatcher
    //     isInDebugMode:
    //         true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
    //     );
    // if (Platform.isAndroid) {
    //   Workmanager().registerPeriodicTask(
    //     "recurring-bill-task-identifier",
    //     "recurringBillReminderTask",
    //     frequency: Duration(minutes: 15),
    //   );
    // } else {
    //   await flutterLocalNotificationsPlugin.zonedSchedule(
    //     id,
    //     title,
    //     body,
    //     _nextInstance(interval, date, localTimezone),
    //     notificationDetails(),
    //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    //     uiLocalNotificationDateInterpretation:
    //         UILocalNotificationDateInterpretation.absoluteTime,
    //     matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    //   );
    // }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstance(interval, date, localTimezone),
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );

    // await flutterLocalNotificationsPlugin.periodicallyShow(
    //   id,
    //   title,
    //   body,
    //   RepeatInterval.everyMinute,
    //   notificationDetails(),
    //   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    // );
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
              now.month,
              convertedDate.day,
              convertedDate.hour,
              convertedDate.minute,
            ),
            location);
        if (scheduledDate.isBefore(now)) {
          // Check if the month has 30 or 31 days
          if (has31Days(scheduledDate.month + 1)) {
            //add 31 days
            scheduledDate = scheduledDate.add(Duration(days: 31));
          } else {
            // If the next month has fewer days, adjust the day to the last day of the month
            scheduledDate = scheduledDate.add(Duration(
                days:
                    getNumberOfDays(scheduledDate.year, scheduledDate.month)));
          }
        }
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
    }
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
