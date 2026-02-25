import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Models/WorkoutModel.dart';
import 'package:gms_flutter/Modules/Dashboard/Helper/WorkoutDetails.dart';
import 'package:gms_flutter/Shared/Constant.dart';

import '../../BLoC/Manager.dart';
import '../../Shared/Components.dart';


class MyFavorites extends StatefulWidget {
  const MyFavorites({super.key});

  @override
  State<MyFavorites> createState() => _MyFavoritesState();
}

class _MyFavoritesState extends State<MyFavorites> {
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
        return Scaffold(
          backgroundColor: Constant.scaffoldColor,
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: reusableText(
              content: 'My Favorites',
              fontSize: 22.0,
              fontColor: Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: Colors.black,
            centerTitle: true,
            elevation: 0,
          ),
          body: ConditionalBuilder(
            condition: state is! LoadingState,
            builder: (context) {
              if (state is SuccessState) {
                return manager.userFavorites.isEmpty
                    ? const Center(
                        child: Text(
                          "No favorites yet.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: manager.userFavorites.length,
                        itemBuilder: (context, index) {
                          final workout = manager.userFavorites.elementAt(
                            index,
                          );
                          return _buildFavoriteCard(workout, index, context);
                        },
                      );
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      reusableText(
                        content: 'Connection error!',
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                      const SizedBox(height: 10.0),
                      GestureDetector(
                        onTap: () {
                          manager.getUserFavorites();
                        },
                        child: Container(
                          height: 50,
                          width: Constant.screenWidth / 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.teal.shade700,
                                Constant.scaffoldColor,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.shade700,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "Retry",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
            fallback: (context) =>
                Center(child: const CircularProgressIndicator()),
          ),
        );
      },
    );
  }

  Widget _buildFavoriteCard(
    WorkoutModel workout,
    int index,
    BuildContext context,
  ) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(workout.id),
      tween: Tween(begin: 0.9, end: 1),
      duration: Duration(milliseconds: 500 + (index * 120)),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: GestureDetector(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutDetails(workout: workout),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [Colors.teal.shade700, Constant.scaffoldColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(102),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 60,
                  width: 60,
                  color: Colors.black26,
                  child:
                  (workout.imagePath != null)
                      ? Image.network(
                          Constant.mediaURL + workout.imagePath!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Icon(
                                  Icons.fitness_center,
                                  size: 60,
                                  color: Colors.greenAccent,
                                ),
                              ),
                        )
                      : Icon(
                        Icons.fitness_center,
                        size: 60,
                        color: Colors.greenAccent,
                      ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  workout.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                onPressed: () {
                  ReusableComponents.deleteDialog<Manager>(context, () async {
                    manager.deleteFavoriteRecord(workout.id.toString());
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
