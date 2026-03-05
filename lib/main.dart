import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter/BLoC/ChatManager.dart';
import 'package:gms_flutter/BLoC/ThemeManager.dart';
import 'package:gms_flutter/Modules/Base.dart';
import 'package:gms_flutter/Modules/Login.dart';
import 'package:gms_flutter/Modules/OnBoarding.dart';
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
  // Initialize Dio
  Dio_Linker.init();
  // Initialize Shared Preference
  await SharedPrefHelper.init();
  // Initialize Pusher
  await Pusher_Linker.init();
  // Initialize local notifications
  await LocalNotificationService.init();
  // Initialize Firebase
  await Firebase.initializeApp();
  // Initialize Firebase for background handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // Start listening to Firebase messages
  FirebaseMessagingService();
  // Check suitable Route
  final onboardingDone = SharedPrefHelper.getBool('onboarding_done') ?? false;
  final isLoggedIn = SharedPrefHelper.getBool('is_logged_in') ?? false;
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => Manager()),
        BlocProvider(create: (context) => ThemeManager()),
        BlocProvider(create: (context) => ChatManager()),
      ],
      child: MyApp(onboardingDone: onboardingDone, isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool onboardingDone;
  final bool isLoggedIn;

  const MyApp({
    super.key,
    required this.onboardingDone,
    required this.isLoggedIn,
  });

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    Widget startScreen;
    if (!onboardingDone) {
      startScreen = const OnBoarding();
    } else if (!isLoggedIn) {
      startScreen = const Login();
    } else {
      startScreen = const Base();
    }
    Constant.initializeScreenSize(context);
    return BlocBuilder<ThemeManager, ThemeData>(
      builder: (context, theme) {
        return MaterialApp(
          theme: theme,
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          home: startScreen,
        );
      },
    );
  }
}
