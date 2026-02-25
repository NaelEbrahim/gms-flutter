import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gms_flutter/BLoC/Manager.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Models/EventModel.dart';
import 'package:gms_flutter/Modules/Info/EventInfo.dart';
import 'package:gms_flutter/Shared/Components.dart';
import 'package:gms_flutter/Shared/Constant.dart';

class MyEvents extends StatefulWidget {
  const MyEvents({super.key});

  @override
  State<MyEvents> createState() => _MyEventsState();
}

class _MyEventsState extends State<MyEvents> {
  late Manager manager;

  @override
  void initState() {
    super.initState();
    manager = Manager.get(context);
    manager.getUserEvents();
  }

  @override
  void dispose() {
    manager.userEvents.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<Manager, BLoCStates>(
      listener: (context, state) {
        if (state is ErrorState) {
          ReusableComponents.showToast(
            state.error.toString(),
            background: Colors.red,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Constant.scaffoldColor,
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: Colors.black,
            centerTitle: true,
            title: const Text(
              "My Events",
              style: TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          body: ConditionalBuilder(
            condition: state is! LoadingState,
            fallback: (_) => const Center(child: CircularProgressIndicator()),
            builder: (_) {
              if (state is SuccessState) {
                if (manager.userEvents.isEmpty) {
                  return const Center(
                    child: Text(
                      "No subscribed events yet.",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: manager.userEvents.length,
                  itemBuilder: (context, index) {
                    final event = manager.userEvents[index];
                    return _buildEventCard(context, event, index);
                  },
                );
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Connection error!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => manager.getUserEvents(),
                      child: Container(
                        height: 50,
                        width: Constant.screenWidth / 3,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal.shade700,
                              Constant.scaffoldColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text(
                            "Retry",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventInfo(event: event, isSubscribed: true),
          ),
        );
      },
      child: TweenAnimationBuilder<double>(
        key: ValueKey(event.id),
        tween: Tween(begin: 0.9, end: 1),
        duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 300)),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
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
                color: Colors.black.withAlpha(100),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  height: 70,
                  width: 70,
                  child: event.imagePath != null
                      ? Image.network(
                          Constant.mediaURL + event.imagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            FontAwesomeIcons.medal,
                            size: 50,
                            color: Colors.greenAccent,
                          ),
                        )
                      : const Icon(
                          FontAwesomeIcons.medal,
                          size: 50,
                          color: Colors.greenAccent,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${event.startedAt} → "
                      "${event.endedAt}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
