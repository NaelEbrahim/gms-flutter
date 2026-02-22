import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gms_flutter/Models/DietPlanModel.dart';
import 'package:gms_flutter/Models/ProfileModel.dart';
import 'package:gms_flutter/Shared/Components.dart';
import 'package:gms_flutter/Shared/Constant.dart';

class DietPlanInfo extends StatelessWidget {
  final String title;
  final ProfileDataModel coach;
  final Map<String, DayMealsModel>? schedule;

  const DietPlanInfo({
    super.key,
    required this.title,
    required this.coach,
    this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff212121),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: reusableText(
          content: 'Diet-Plan Info',
          fontSize: 22.0,
          fontColor: Colors.greenAccent,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderCoachCard(),
          const SizedBox(height: 20),
          _buildSchedule(),
        ],
      ),
    );
  }

  Widget _buildHeaderCoachCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant, color: Colors.greenAccent, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white12),
          const SizedBox(height: 16),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: (coach.profileImagePath != null)
                    ? Image.network(
                        Constant.mediaURL + coach.profileImagePath.toString(),
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.person,
                          color: Colors.greenAccent,
                          size: 36,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 36,
                        color: Colors.greenAccent,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Audit Coach',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${coach.firstName} ${coach.lastName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: schedule!.entries.map((entry) {
        final dayMeals = entry.value;

        final allMeals = [
          ...?dayMeals.breakfast,
          ...?dayMeals.lunch,
          ...?dayMeals.dinner,
          ...?dayMeals.snack,
        ];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: _cardDecoration(),
          child: ExpansionTile(
            iconColor: Colors.greenAccent,
            collapsedIconColor: Colors.white70,
            title: Text(
              entry.key,
              style: const TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: allMeals.map((meal) {
              final mealMap = {
                "title": meal.title,
                "image": meal.imagePath,
                "calories": meal.totalCalories,
                "quantity": meal.quantity,
                "description": meal.description,
              };
              return _buildMealCard(mealMap);
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(102),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: (meal['image'] != null)
                ? Image.network(
                    Constant.mediaURL + meal['image'],
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.restaurant,
                      color: Colors.greenAccent,
                      size: 30,
                    ),
                  )
                : const Icon(Icons.restaurant, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal["title"],
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Calories: ${meal["calories"]} kcal",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  "Quantity: ${meal["quantity"]}",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  meal["description"],
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: LinearGradient(
        colors: [Colors.teal.shade700, Colors.black87],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(64),
          blurRadius: 6,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
