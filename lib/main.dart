import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spot/core/permission_handler.dart';
import 'package:spot/firebase_helper/local_notification_helper.dart';
import 'package:spot/firebase_options.dart';
import 'package:spot/providers/chat_provider.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/providers/group_provider.dart';
import 'package:spot/providers/profile_provider.dart';
import 'package:spot/providers/socket_provider.dart';
import 'package:spot/providers/user_provider.dart';
import 'package:spot/services/http_overrides.dart';
import 'package:spot/socket/app_lifecycle_reactor.dart';
import 'package:spot/ui/screens/auth/login.dart';
import 'package:spot/ui/screens/chatScreens/chatlist/chat_list.dart';
import 'package:spot/ui/screens/chatScreens/userchats/group_chat.dart';
import 'package:spot/ui/screens/chatScreens/userchats/user_chat.dart';
import 'package:spot/ui/screens/chatScreens/userchats/user_chats.dart';
import 'firebase_helper/fcm_notification_helper.dart';
import 'firebase_helper/notification_service.dart';

// @pragma('vm:entry-point')

//   Future<void> onBackground(RemoteMessage remoteMessage) async{
//   log("=====BACKGROUND NOTIFICATION=======");
//   log("Title: ${remoteMessage.notification!.title}");
//   log("Body: ${remoteMessage.notification!.body}");
//   log("Custom Data: ${remoteMessage.data}");
//   log("===================");
// }
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

String stripHtmlTags(String htmlText) {
  return htmlText.replaceAll(RegExp(r'<[^>]*>'), '').trim();
}

@pragma('vm:entry-point')
void setupFCMListeners() {
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    final data = message.data;
    final type = data['type'];
    final userId = data['iUserId'];

    if (type == 'newMessage' && userId != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => Login(),
        ),
      );
    }
  });

  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      final data = message.data;
      final type = data['type'];
      final userId = data['iUserId'];

      if (type == 'newMessage' && userId != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => Login(),
          ),
        );
      }
    }
  });
}

Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  final title = message.notification!.title;
  final rawBody = message.notification!.body;
  final cleanBody = stripHtmlTags(rawBody!);

  await LocalNotificationHelper.localNotificationHelper.showSimpleNotifications(
    id: title!,
    name: cleanBody,
  );
}

// @pragma('vm:entry-point')
// Future<void> onbackground(RemoteMessage remotemessage) async {
//   log("=====BACKGROUND NOTIFICATION=======");
//   log("Title: ${remotemessage.notification!.title}");
//   log("Body: ${remotemessage.notification!.body}");
//   log("Custom Data: ${remotemessage.data}");
//   log("===================");
// }
// @pragma('vm:entry-point')
// Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
//   final title = message.notification?.title ?? "No Title";
//   final rawBody = message.notification?.body ?? "No Body";
//   final cleanBody = stripHtmlTags(rawBody);
//   final imageUrl = message.data['fileUrl']; // Assume your backend includes this
//
//   if (imageUrl != null && imageUrl.isNotEmpty) {
//     await LocalNotificationHelper.localNotificationHelper.showBigPictureNotifications(
//       title: title,
//       description: cleanBody,
//       imageUrl: imageUrl,
//     );
//   } else {
//     await LocalNotificationHelper.localNotificationHelper.showSimpleNotifications(
//       id: title,
//       name: cleanBody,
//     );
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
  // await LocalNotificationHelper.localNotificationHelper.initLocalNotifications();
  await FcmNotificationHelper.requestNotificationPermissions();

  await NotificationService.requestPermissions();
  await FcmNotificationHelper.instance.initFcm();
  reqPermission();

  FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
    final title = remoteMessage.notification?.title ?? "No Title";
    final rawBody = remoteMessage.notification?.body ?? "No Body";
    final cleanBody = stripHtmlTags(rawBody);

    LocalNotificationHelper.localNotificationHelper.showSimpleNotifications(
      id: title,
      name: cleanBody,
    );
  });

  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());

  // runApp(MultiProvider(
  //   providers: [
  //     ChangeNotifierProvider(create: (_) => UserProvider()),
  //     ChangeNotifierProvider(create: (_) => GroupProvider()),
  //     ChangeNotifierProvider(create: (_) => DataListProvider()),
  //     ChangeNotifierProvider(create: (_) => ProfileProvider()),
  //     ChangeNotifierProvider(create: (_) => ChatProvider()),
  //     ChangeNotifierProvider(create: (_) => SocketProvider()),
  //   ],
  //   child: const MyApp(),
  // ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? isLoggedIn;
  Key providerKey = UniqueKey();
  final AppLifecycleReactor appLifecycleReactor = AppLifecycleReactor();

  @override
  void initState() {
    print("Message from office pc");
    super.initState();
    checkLoginStatus();
  }

  @override
  void dispose() {
    super.dispose();
    // appLifecycleReactor.stopObserving();
  }

  void checkLoginStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool loggedIn = prefs.getBool('isLoggedIn') ?? false;
      setState(() {
        isLoggedIn = loggedIn;
      });
    } catch (error) {
      setState(() {
        isLoggedIn = false;
      });
    }
  }

  void checkNotificationPayload() {}

  @override
  Widget build(BuildContext context) {
    void resetProviders() {
      setState(() {
        providerKey = UniqueKey();
        isLoggedIn = false;
      });
    }

    if (isLoggedIn != null && isLoggedIn!) {
      appLifecycleReactor
          .startObserving(context); // Pass context to start observing lifecycle
    }

    // print("IsLogged in $isLoggedIn");

    return MultiProvider(
      key: providerKey,
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => DataListProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => SocketProvider()),
      ],
      child: ScreenUtilInit(
        // google pixel 9a screen size
        designSize: const Size(411, 923),
        ensureScreenSize: true,
        minTextAdapt: true,
        splitScreenMode: true,
        child: MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            // theme: ThemeData(brightness: Brightness.light),
            routes: {
              '/login': (context) => Login(),
              '/chatList': (context) => ChatList(onLogout: resetProviders),
              '/userChat': (context) => const UserChat(),
              '/groupChat': (context) => const GroupChat(),
            },
            // home: Login()
            home: isLoggedIn == null
                ? SafeArea(
                    child: const Scaffold(
                        body: Center(child: CircularProgressIndicator())))
                : (isLoggedIn! && isLoggedIn != null
                    ? ChatList(onLogout: resetProviders)
                    : Login())

            // home: const WebSocketService(
            //   token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2VXNlcm5hbWUiOiJraHVzaGkiLCJ2RnVsbE5hbWUiOiIzRnM5YjNtNnM5YTYiLCJMb2dpblRpbWUiOjEwNDkwMDU2MjkwMCwiaWF0IjoxNzQ4MzQyNzE1fQ.5iBXTBtJm7w0JkTfpm-gZFNuhsFDNBi4u7D-08bA3Rk',
            //   superUser: false,
            // ),
            ),
      ),
    );
  }
}
