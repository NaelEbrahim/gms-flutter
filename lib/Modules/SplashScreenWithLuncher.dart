import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gms_flutter/Modules/Base.dart';
import 'package:gms_flutter/Modules/Login.dart';
import 'package:gms_flutter/Modules/OnBoarding.dart';
import 'package:gms_flutter/Remote/Dio_Linker.dart';
import 'package:gms_flutter/Remote/FCM.dart';
import 'package:gms_flutter/Remote/Pusher_Linker.dart';
import 'package:gms_flutter/Shared/BackgroundHandler.dart';
import 'package:gms_flutter/Shared/LocalNotification.dart';
import 'package:gms_flutter/Shared/SharedPrefHelper.dart';

class SplashScreen extends StatefulWidget {
  final Future<void> Function() onInitializationComplete;

  const SplashScreen({super.key, required this.onInitializationComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    // Logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    );
    _logoController.repeat(reverse: true);
    // Start async initialization
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    final steps = [
      () => Dio_Linker.init(),
      () => SharedPrefHelper.init(),
      () => Pusher_Linker.init(),
      () => LocalNotificationService.init(),
      () => Firebase.initializeApp(),
      () async {
        FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler,
        );
        FirebaseMessagingService();
      },
    ];

    for (int i = 0; i < steps.length; i++) {
      await steps[i]();
      setState(() => _progress = (i + 1) / steps.length);
    }

    await widget.onInitializationComplete();
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _logoAnimation,
              child: Image.asset('images/logo.png', width: 120, height: 120),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 6,
                    color: Colors.teal,
                    backgroundColor: Colors.white24,
                  ),
                  Center(
                    child: Text(
                      '${(_progress * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Initializing...',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class Launcher extends StatelessWidget {
  const Launcher({super.key});

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      onInitializationComplete: () async {
        // Determine start screen
        final onboardingDone =
            SharedPrefHelper.getBool('onboarding_done') ?? false;
        final isLoggedIn = SharedPrefHelper.getBool('is_logged_in') ?? false;
        Widget startScreen = !onboardingDone
            ? const OnBoarding()
            : !isLoggedIn
            ? const Login()
            : const Base();

        // Navigate
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => startScreen));
      },
    );
  }
}
