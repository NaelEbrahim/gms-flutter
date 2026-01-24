import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gms_flutter/Shared/Components.dart';
import '../Dashboard/My Favorites.dart';
import '../Dashboard/MyClasses.dart';
import '../Dashboard/MyDietPlans.dart';
import '../Dashboard/MyHealthInfo.dart';
import '../Dashboard/MyPrivateCoaches.dart';
import '../Dashboard/MySessions.dart';

class Dashboard extends StatelessWidget {
  Dashboard({super.key});

  final items = [
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
  ];

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 10.0),
    child: GridView.builder(
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 25,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
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
    ),
  );
}
