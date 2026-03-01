import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gms_flutter/Modules/Dashboard/Coach/CoachClasses.dart';
import 'package:gms_flutter/Modules/Dashboard/Coach/CoachDiet-Plans.dart';
import 'package:gms_flutter/Modules/Dashboard/Coach/CoachSessions.dart';
import 'package:gms_flutter/Modules/Dashboard/Coach/CoachTrainees.dart';
import 'package:gms_flutter/Modules/Dashboard/MyEvents.dart';
import 'package:gms_flutter/Modules/Dashboard/MyPrograms.dart';
import 'package:gms_flutter/Shared/Components.dart';
import 'package:gms_flutter/Shared/SecureStorage.dart';
import '../Dashboard/My Favorites.dart';
import '../Dashboard/MyClasses.dart';
import '../Dashboard/MyDietPlans.dart';
import '../Dashboard/MyHealthInfo.dart';
import '../Dashboard/MyPrivateCoaches.dart';
import '../Dashboard/MySessions.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late String role = '-';

  @override
  void initState() {
    super.initState();
    TokenStorage.readRole().then((r) {
      setState(() => role = r ?? '-');
    });
  }

  final userItems = [
    {
      "title": "My Classes",
      "icon": FontAwesomeIcons.personRunning,
      "screen": MyClasses(),
    },
    {"title": "My Sessions", "icon": Icons.schedule, "screen": MySessions()},
    {
      "title": "My Diet Plan",
      "icon": Icons.restaurant_outlined,
      "screen": MyDietPlans(),
    },
    {
      "title": "My Private Coach",
      "icon": Icons.sports_kabaddi_outlined,
      "screen": MyPrivateCoaches(),
    },
    {
      "title": "My Health Info",
      "icon": FontAwesomeIcons.heartPulse,
      "screen": MyHealthInfo(),
    },
    {"title": "My Favorites", "icon": Icons.star, "screen": MyFavorites()},
    {
      "title": "My Events",
      "icon": FontAwesomeIcons.medal,
      "screen": MyEvents(),
    },
    {
      "title": "My Programs",
      "icon": FontAwesomeIcons.list,
      "screen": MyPrograms(),
    },
  ];

  final coachItems = [
    {
      "title": "Coaching Classes",
      "icon": FontAwesomeIcons.personRunning,
      "screen": CoachClasses(),
    },
    {
      "title": "Coaching Sessions",
      "icon": Icons.schedule,
      "screen": CoachSessions(),
    },
    {
      "title": "Managed Diet-Plans",
      "icon": Icons.restaurant_outlined,
      "screen": CoachDiets(),
    },
    {
      "title": "Managed Trainees",
      "icon": Icons.sports_kabaddi_outlined,
      "screen": CoachTrainees(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: (role == 'User') ? userItems.length : coachItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 25,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final item = (role == 'User') ? userItems[index] : coachItems[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => item['screen'] as Widget),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white12,
              border: Border.all(color: Colors.white54),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item['icon'] as IconData,
                  size: 60,
                  color: Colors.greenAccent,
                ),
                const SizedBox(height: 12),
                reusableText(
                  content: item['title'] as String,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontColor: Colors.white,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
