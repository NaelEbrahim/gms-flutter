import 'package:flutter/material.dart';
import 'package:gms_flutter/Models/ProgramModel.dart';

import '../../../Shared/Constant.dart';
import 'WorkoutList.dart';

class ProgramDays extends StatelessWidget {
  final ProgramModel program;

  const ProgramDays({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    final days = program.schedule?.days?.keys.toList();

    return Scaffold(
      backgroundColor: Constant.scaffoldColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          program.name.toString(),
          style: const TextStyle(
            color: Colors.greenAccent,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: days?.length ?? 0,
        itemBuilder: (context, index) {
          final day = days?[index];

          final muscles = program
              .schedule!
              .days![day]!
              .muscleGroups!
              .keys
              .toList();

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkoutList(
                    dayName: day.toString(),
                    musclesMap: program.schedule!.days![day]!.muscleGroups!,
                  ),
                ),
              );
            },
            child: _buildDayCard(day.toString(), muscles, index),
          );
        },
      ),
    );
  }

  // === Day Card with Muscles ===
  Widget _buildDayCard(String day, List<String> muscles, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1),
      duration: Duration(milliseconds: 400 + (index * 150)),
      builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.teal.shade700, Colors.black87],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day Row
            Row(
              children: [
                const Icon(Icons.calendar_month,
                    size: 32, color: Colors.greenAccent),
                const SizedBox(width: 14),
                Text(
                  day.replaceAll("_", " "),
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white70, size: 18),
              ],
            ),

            const SizedBox(height: 14),

            // Muscles List (chips)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: muscles
                  .map(
                    (m) => Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.greenAccent, width: 1),
                  ),
                  child: Text(
                    m,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ),
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
