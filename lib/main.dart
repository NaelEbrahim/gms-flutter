import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter/BLoC/ChatManager.dart';
import 'package:gms_flutter/BLoC/ThemeManager.dart';
import 'package:gms_flutter/Modules/SplashScreenWithLuncher.dart';
import 'package:gms_flutter/Shared/Constant.dart';

import 'BLoC/Manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => Manager()),
        BlocProvider(create: (context) => ThemeManager()),
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

    return BlocBuilder<ThemeManager, ThemeData>(
      builder: (context, theme) {
        return MaterialApp(
          theme: theme,
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          home: const Launcher(),
        );
      },
    );
  }
}
