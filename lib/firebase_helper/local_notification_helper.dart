import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationHelper {
  LocalNotificationHelper._();

  static final LocalNotificationHelper localNotificationHelper =
      LocalNotificationHelper._();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initLocalNotifications() async {
    AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("mipmap/ic_launcher");

    DarwinInitializationSettings iOSInitializationSettings =
        DarwinInitializationSettings();

    InitializationSettings initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: iOSInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Future<void> showSimpleNotifications({required String id, required String name}) async{
  //   await initLocalNotifications();
  //
  //   AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(id, name,priority: Priority.max,importance: Importance.max,);
  //
  //   DarwinNotificationDetails IOSNotificationDetails = DarwinNotificationDetails();
  //
  //   NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails,iOS: IOSNotificationDetails);
  //
  //   await flutterLocalNotificationsPlugin.show(1, id, name, notificationDetails);
  // }

  Future<void> showSimpleNotifications({
    required String id,
    required String name,
    String? payload, // 👈 allow payload
  }) async {
    await initLocalNotifications();

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      id,
      name,
      priority: Priority.max,
      importance: Importance.max,
    );

    DarwinNotificationDetails iOSNotificationDetails =
        DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      1, // notification ID
      id, // title
      name, // body
      notificationDetails,
      payload: payload, // 👈 pass custom payload
    );
  }

  // Future<void> showBigPictureNotifications({required String title, required String description}) async{
  //    await initLocalNotifications();
  //
  //    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(title, description, priority: Priority.max, importance: Importance.max,styleInformation: BigPictureStyleInformation(DrawableResourceAndroidBitmap("mipmap/ic_launcher")));
  //
  //    DarwinNotificationDetails IOSNotificationsDetails = DarwinNotificationDetails();
  //
  //    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails,iOS: IOSNotificationsDetails);
  //
  //    await flutterLocalNotificationsPlugin.show(1, title, description, notificationDetails);
  //  }

  Future<void> showMediaStyleNotifications() async {
    await initLocalNotifications();

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      "SN",
      "Simple Notification",
      priority: Priority.max,
      importance: Importance.max,
      styleInformation: BigPictureStyleInformation(
        DrawableResourceAndroidBitmap("mipmap/ic_launcher"),
      ),
    );

    DarwinNotificationDetails iOSNotificationDetails =
        DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iOSNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        1, "Simple Title", "Dummy Description", notificationDetails);
  }
}
