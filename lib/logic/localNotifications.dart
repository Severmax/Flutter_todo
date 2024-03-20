import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_todo/logic/Task.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_todo/logic/databaseHelper.dart';
import 'package:permission_handler/permission_handler.dart';


  class Noti{

    static final Noti _self = Noti.internal();
    factory Noti() => _self;
    Noti.internal();

    var _platformChannelSpecifics;

    // cоздание объекта FlutterLocalNotificationsPlugin
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    void requestNotificationPermission() async {
      // проверяем, есть ли уже разрешение на уведомления
      var status = await Permission.notification.status;

      // если разрешение не получено, запрашиваем его
      if (!status.isGranted) {
        // запрашиваем разрешение
        await Permission.notification.request();
      }
    }

    // инициализация настроек уведомлений и канала уведомлений
    Future<void> initNotifications() async {
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('mipmap/ic_launcher');


      final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();
      final LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(
          defaultActionName: 'Open notification');

      final InitializationSettings initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
          linux: initializationSettingsLinux);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'flutter_todo_noti',
        'flutter_todo',
        channelDescription: 'Дозволяє отримувати повідомлення про завдання за 30хв до запланованого часу.',

        playSound: true,
        // sound: RawResourceAndroidNotificationSound('notification'),
        importance: Importance.max,
        priority: Priority.high,


      );

      _platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics);

      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Europe/Helsinki'));

      requestNotificationPermission();    }

    // cоздание ежедневного уведомления в 10 утра
    Future<void> setDeiliNotification() async{
      var now = tz.TZDateTime.now(tz.local);
      print(now);
      var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 8);
      print(scheduledDate);

      for(int i = 10000; i<10007; i++){
        var data = await DatabaseHelper().getTasksForDay(scheduledDate, false);
        print("$i - ітерація(DailiNoti)");
        flutterLocalNotificationsPlugin.zonedSchedule(
          i,
          'Добрий ранок!',
          'Кількість завдань на сьогодні: ${data.length}',
          scheduledDate,
          _platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
        );
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }


    }

    // отправка уведомления за 30 минут до указанного времени
    void setNotification(Task task) async {


      DateTime plannedDateTime = DateTime(
        task.date!.year,
        task.date!.month,
        task.date!.day,
        task.time!.hour,
        task.time!.minute,
      ).subtract(Duration(minutes: 30));


      tz.TZDateTime plannedTZDateTime = tz.TZDateTime.from(plannedDateTime, tz.local);


      print("===========");
      print(plannedTZDateTime);
      print("===========");

      await flutterLocalNotificationsPlugin.zonedSchedule(
        task.id!,
        'Нагадування про завдання',
        'Завдання "${task.heading}" закінчеться через 30 хвилин.',
        plannedTZDateTime,
        _platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    // удаление уведомления по идентификатору
    void cancelNotification(int notificationId) async {
      await flutterLocalNotificationsPlugin.cancel(notificationId);
    }

  }








