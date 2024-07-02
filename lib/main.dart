import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/componen/color.dart';
import 'app/data/endpoint.dart';
import 'app/data/publik.dart';
import 'app/routes/app_pages.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart'; // Import Pusher

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin(); // Declare globally

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = MyHttpOverrides();
  startPollingNotifications();
  await GetStorage.init('token-mekanik');

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight
  ]);

  final AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}

void startPollingNotifications() {
  const pollingInterval = Duration(minutes: 1);

  Timer.periodic(pollingInterval, (timer) async {
    showPeriodicNotificationLocalNotification('Vale Indonesia Mekanik', 'Ada Booking Masuk'); // Call showPeriodicNotification
  });
}

void showPeriodicNotificationLocalNotification(String title, String body, {String? sound}) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'high_importance_channel',
    'High Importance Notifications',
    channelDescription: 'This channel is used for important notifications.',
    importance: Importance.max,
    priority: Priority.high,
    sound: sound != null ? RawResourceAndroidNotificationSound(sound) : null,
    playSound: true,
    showWhen: false,
  );
  var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: 'item x',
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late PusherChannelsFlutter pusher;
  final String appId = "1827229";
  final String key = "5c463cc9a2fdf08932b5";
  final String secret = "521202e4d68dc816c054";
  final String cluster = "ap1";

  @override
  void initState() {
    super.initState();
    initPusher();
  }

  Future<void> initPusher() async {
    pusher = PusherChannelsFlutter.getInstance();
    try {
      await pusher.init(
        apiKey: key,
        cluster: cluster,
        onEvent: (event) {
          print("Event received: $event");
          showLocalNotification(event.eventName, event.data);
        },
        onConnectionStateChange: (currentState, previousState) {
          print(
              "Connection state changed from $previousState to $currentState");
        },
        onError: (message, code, exception) {
          print("Connection error: $message");
        },
      );
      await pusher.connect();
      await pusher.subscribe(
        channelName: 'my-channel',
        onEvent: (event) {
          print("Event received: ${event.eventName}");
          print("Event data: ${event.data}");
          showLocalNotification(event.eventName, event.data);
        },
      );
    } catch (e) {
      print("Pusher connection error: $e");
    }
  }

  void showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'high_importance_channel', // channel_id
      'High Importance Notifications', // channel_name
      channelDescription:
      'This channel is used for important notifications.', // channel_description
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Vale Indonesia Mekanik',
      'Ada Booking Masuk',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  void showPeriodicNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'repeat_channel_id', // channel_id
      'Repeat Notifications', // channel_name
      channelDescription: 'This channel is used for repeating notifications.', // channel_description
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.periodicallyShow(
      1,
      'Periodic Notification',
      'This notification repeats every 1 minute',
      RepeatInterval.everyMinute,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  @override
  Widget build(BuildContext context) {
    final token = Publics.controller.getToken.value;
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Mekanik Vale Indonesia",
      initialRoute:
      token.isEmpty ? AppPages.INITIAL : Routes.SPLASHCREEN,
      getPages: AppPages.routes,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: AppColors.contentColorWhite,
          foregroundColor: AppColors.contentColorBlack,
          iconTheme: IconThemeData(color: AppColors.contentColorBlack),
        ),
      ),
    );
  }
}
