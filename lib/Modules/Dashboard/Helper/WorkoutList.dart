import 'package:flutter/material.dart';

import '../../../Models/WorkoutModel.dart';
import '../../../Shared/Components.dart';
import '../../../Shared/Constant.dart';
import 'WorkoutDetails.dart';

class WorkoutList extends StatelessWidget {
  final String dayName;
  final Map<String, List<WorkoutModel>> musclesMap;

  const WorkoutList({
    super.key,
    required this.dayName,
    required this.musclesMap,
  });

  @override
  Widget build(BuildContext context) {
    final muscleGroups = musclesMap.keys.toList();
    final totalMuscles = muscleGroups.length;
    final totalExercises = musclesMap.values.fold<int>(
      0,
      (previousValue, workouts) => previousValue + workouts.length,
    );

    return Scaffold(
      backgroundColor: Constant.scaffoldColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          dayName.replaceAll("_", " "),
          style: const TextStyle(
            color: Colors.greenAccent,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: muscleGroups.length + 1, // +1 → summary card
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Row(
              children: [
                Expanded(
                  child: buildSummaryCard(
                    title: "Muscle Groups",
                    number: totalMuscles,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildSummaryCard(
                    title: "Exercises",
                    number: totalExercises,
                  ),
                ),
              ],
            );
          }
          final muscle = muscleGroups[index - 1];
          final workouts = musclesMap[muscle]!;
          return _buildMuscleSection(context, muscle, workouts);
        },
      ),
    );
  }

  Widget buildSummaryCard({required String title, required int number}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal, Colors.black87],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(115),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            "$number",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleSection(
    BuildContext context,
    String muscle,
    List<WorkoutModel> workouts,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [Colors.teal.shade700, Colors.black87],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(102),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withAlpha(102),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: MuscleHighlightIcon(muscleName: muscle, size: 80),
              ),
              const SizedBox(height: 10),
              Text(
                muscle.toUpperCase(),
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: workouts.map((w) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkoutDetails(workout: w),
                      ),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withAlpha(25)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(64),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            w.title,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.white54,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
