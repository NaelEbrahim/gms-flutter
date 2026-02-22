import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter/BLoC/ChatManager.dart';
import 'package:gms_flutter/Modules/Base.dart';
import 'package:gms_flutter/Remote/Dio_Linker.dart';
import 'package:gms_flutter/Remote/FCM.dart';
import 'package:gms_flutter/Shared/Constant.dart';
import 'package:gms_flutter/Shared/LocalNotification.dart';

import 'BLoC/Manager.dart';
import 'Remote/Pusher_Linker.dart';
import 'Shared/BackgroundHandler.dart';
import 'Shared/SharedPrefHelper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.delayed(Duration.zero);
  // Initialize Firebase
  await Firebase.initializeApp();
  // Initialize local notifications
  await LocalNotificationService.init();
  // Register background handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // Start listening to Firebase messages
  FirebaseMessagingService();
  // Initialize Dio
  Dio_Linker.init();
  // Initialize Shared Preference
  await SharedPrefHelper.init();
  // Initialize Pusher
  await Pusher_Linker.init();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => Manager()),
        BlocProvider(create: (context) => ChatManager()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    Constant.initializeScreenSize(context);
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      debugShowCheckedModeBanner: false,
      home: Base(),
    );
  }
}
