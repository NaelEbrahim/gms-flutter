import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gms_flutter/BLoC/Manager.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Models/PrivateCoachModel.dart';

import '../../Shared/Components.dart';
import '../../Shared/Constant.dart';

class MyPrivateCoaches extends StatelessWidget {
  Manager? _manager;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => Manager()..userCoaches(),
      child: BlocConsumer<Manager, BLoCStates>(
        listener: (context, state) {
          if (state is ErrorState) {
            ReusableComponents.showToast(
              state.error.toString(),
              background: Colors.red,
            );
          }
        },
        builder: (context, state) {
          _manager = Manager.get(context);
          return Scaffold(
            backgroundColor: const Color(0xff212121),
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.white),
              title: reusableText(
                content: 'My Private Coaches',
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
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _manager?.userPrivateCoaches.length,
                    itemBuilder: (context, index) {
                      final coach = _manager?.userPrivateCoaches.elementAt(
                        index,
                      );
                      return _buildCoachCard(context, coach!, index);
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
                            _manager?.userCoaches();
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
      ),
    );
  }

  Widget _buildCoachCard(
    BuildContext context,
    PrivateCoachModel coach,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1),
      duration: Duration(milliseconds: 500 + (index * 150)),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Coach Info Row
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.teal.withOpacity(0.15),
                  child: ClipOval(
                    child: (coach.coach.profileImagePath != 'null')
                        ? Image.network(
                      Constant.mediaURL + coach.coach.profileImagePath.toString(),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        FontAwesomeIcons.circleUser,
                        color: Colors.teal.shade700,
                        size: 80,
                      ),
                    )
                        : Icon(
                      FontAwesomeIcons.circleUser,
                      color: Colors.teal.shade700,
                      size: 80,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${coach.coach.firstName} ${coach.coach.lastName}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kick Boxing',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  coach.isActive ? "Active" : "Inactive",
                  style: TextStyle(
                    color: coach.isActive
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// Rate Section
            if (coach.rate != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      for (int i = 1; i <= 5; i++)
                        Icon(
                          i <= coach.rate!.round()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.greenAccent,
                          size: 22,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.edit),
                        label: const Text("Change Rate"),
                        onPressed: () {
                          _showRateDialog(context, coach);
                        },
                      ),
                      const Spacer(),
                      Text(
                        'Joined At:\n${coach.startedAt}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      )
                    ],
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.star),
                label: const Text("Add Rate"),
                onPressed: () {
                  _showRateDialog(context, coach);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showRateDialog(BuildContext context, PrivateCoachModel coach) {
    int tempRate = coach.rate?.round() ?? 0;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xff2a2a2a),
        title: const Text(
          "Rate Coach",
          style: TextStyle(color: Colors.greenAccent),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 1; i <= 5; i++)
                IconButton(
                  icon: Icon(
                    i <= tempRate ? Icons.star : Icons.star_border,
                    color: Colors.greenAccent,
                    size: 30,
                  ),
                  onPressed: () {
                    setDialogState(() => tempRate = i);
                  },
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white70),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.black,
            ),
            child: const Text("Save"),
            onPressed: () {
              _manager?.updatePrivateCoachRate({
                'coachId': coach.coach.id,
                'rate': tempRate,
              });
            },
          ),
        ],
      ),
    );
  }
}
