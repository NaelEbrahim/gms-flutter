import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Modules/Dashboard/Helper/WorkoutProgress.dart';

import '../../../BLoC/Manager.dart';
import '../../../Models/WorkoutModel.dart';
import '../../../Shared/Constant.dart';

class WorkoutDetails extends StatefulWidget {
  final WorkoutModel workout;

  const WorkoutDetails({super.key, required this.workout});

  @override
  State<WorkoutDetails> createState() => _WorkoutDetailsState();
}

class _WorkoutDetailsState extends State<WorkoutDetails> {
  late Manager manager;

  @override
  void initState() {
    super.initState();
    manager = Manager.get(context);
    manager.getUserFavorites();
  }

  @override
  void dispose() {
    manager.userFavorites.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<Manager, BLoCStates>(
      listener: (context, state) {},
      builder: (context, state) {
        final isFavorite =
            manager.userFavorites.indexWhere(
              (item) => item.id == widget.workout.id,
            ) !=
            -1;
        return Scaffold(
          backgroundColor: Constant.scaffoldColor,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: true,
            title: Text(
              widget.workout.title,
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              if (widget.workout.programWorkoutId != null)
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkoutProgress(
                          program_workout_id:
                              widget.workout.programWorkoutId ?? 0,
                          workoutModel: widget.workout,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.bar_chart_outlined),
                  color: Colors.white,
                ),
              IconButton(
                icon: Icon(
                  (isFavorite) ? Icons.favorite : Icons.favorite_border,
                  color: Colors.redAccent,
                ),
                onPressed: (state is! LoadingState)
                    ? () {
                        if (isFavorite) {
                          manager.deleteFavoriteRecord(
                            widget.workout.id.toString(),
                          );
                        } else {
                          manager.addToFavorite(widget.workout.id.toString());
                        }
                      }
                    : null,
              ),
            ],
          ),
          body: ConditionalBuilder(
            condition: state is! LoadingState,
            builder: (context) => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildWorkoutImage(),
                const SizedBox(height: 16),
                _detailCard(
                  icon: FontAwesomeIcons.dumbbell,
                  title: "Primary Muscle",
                  value: widget.workout.primaryMuscle,
                ),
                _detailCard(
                  icon: FontAwesomeIcons.person,
                  title: "Secondary Muscles",
                  value: widget.workout.secondaryMuscles ?? "-",
                ),
                if (widget.workout.reps != null && widget.workout.reps! > 0)
                  _detailCard(
                    icon: FontAwesomeIcons.arrowsRotate,
                    title: "Reps",
                    value: widget.workout.reps.toString(),
                  ),
                if (widget.workout.sets > 0)
                  _detailCard(
                    icon: FontAwesomeIcons.layerGroup,
                    title: "Sets",
                    value: widget.workout.sets.toString(),
                  ),
                if (widget.workout.duration != null &&
                    widget.workout.duration! > 1)
                  _detailCard(
                    icon: FontAwesomeIcons.stopwatch,
                    title: "Duration (min)",
                    value: widget.workout.duration.toString(),
                  ),
                _detailCard(
                  icon: FontAwesomeIcons.fire,
                  title: "Total Calories",
                  value: widget.workout.totalBurnedCalories.toString(),
                ),
                _detailCard(
                  icon: FontAwesomeIcons.file,
                  title: "Description",
                  value: widget.workout.description,
                ),
              ],
            ),
            fallback: (context) =>
                Center(child: const CircularProgressIndicator()),
          ),
        );
      },
    );
  }

  Widget _buildWorkoutImage() {
    final hasImage =
        widget.workout.imagePath != null &&
        widget.workout.imagePath!.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 200,
        width: double.infinity,
        color: Colors.black26,
        child: hasImage
            ? Image.network(
                Constant.mediaURL + widget.workout.imagePath!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.image_rounded,
                    size: 60,
                    color: Colors.greenAccent,
                  ),
                ),
              )
            : const Center(
                child: Icon(
                  Icons.fitness_center,
                  size: 60,
                  color: Colors.greenAccent,
                ),
              ),
      ),
    );
  }

  Widget _detailCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade700, Colors.black87],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.greenAccent, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
