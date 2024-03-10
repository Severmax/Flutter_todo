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
    void initNotifications() async {
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
        channelDescription: 'Дозволяє отримувати повідомлення про завдання за 15хв до запланованого часу.',

        playSound: true,
        // sound: RawResourceAndroidNotificationSound('notification'),
        importance: Importance.max,
        priority: Priority.high,


      );

      _platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics);

      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Europe/Helsinki'));

      requestNotificationPermission();

      setDeiliNotification();
    }

    // cоздание ежедневного уведомления в 10 утра
    void setDeiliNotification() async{
      var now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);

      for(int i = 0; i<7; i++){
        var data = await DatabaseHelper().getTasksForDay(scheduledDate);
        flutterLocalNotificationsPlugin.zonedSchedule(
          0,
          'Добрий ранок',
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

    // отправка уведомления за 15 минут до указанного времени
    void setNotification(Task task) async {


      DateTime plannedDateTime = DateTime(
        task.date!.year,
        task.date!.month,
        task.date!.day,
        task.time!.hour,
        task.time!.minute,
      ).subtract(Duration(minutes: 15));


      tz.TZDateTime plannedTZDateTime = tz.TZDateTime.from(plannedDateTime, tz.local);


      print("===========");
      print(plannedTZDateTime);
      print("===========");

      await flutterLocalNotificationsPlugin.zonedSchedule(
        task.id!,
        'Нагадування про завдання',
        'Подія: ${task.description} почнеться через 15 хвилин.',
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








