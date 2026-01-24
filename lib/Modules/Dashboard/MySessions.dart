import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Models/SessionsModel.dart';
import 'package:gms_flutter/Modules/Info/SessionInfo.dart';

import '../../BLoC/Manager.dart';
import '../../Shared/Components.dart';
import '../../Shared/Constant.dart';

class MySessions extends StatelessWidget {
  Manager? _manager;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => Manager()..userSessions(),
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
                content: 'My Sessions',
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
                    itemCount: _manager?.userSessionsModel.length,
                    itemBuilder: (context, index) {
                      final item = _manager?.userSessionsModel.elementAt(index);
                      return _buildSessionCard(context, item!, index);
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
                            _manager?.userSessions();
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

  Widget _buildSessionCard(
    BuildContext context,
    SessionsModel item,
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
            Row(
              children: [
                Text(
                  item.title.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SessionInfo(
                          title: item.title.toString(),
                          coach: item.coach,
                          className: item.className.toString(),
                          classImage: item.classImage.toString(),
                          description: item.description.toString(),
                          startTime: item.startTime.toString(),
                          endTime: item.endTime.toString(),
                          subscribers: item.subscribersCount as int,
                          schedule: item.days as List<String>,
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.info_outlined,
                    color: Colors.greenAccent,
                    size: 28.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "Joined: ${item.joinedAt.toString().substring(0, 10)}",
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            if (item.rate != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      for (int i = 1; i <= 5; i++)
                        Icon(
                          i <= item.rate!.round()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.greenAccent,
                          size: 22,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
                      _showRateDialog(context, item);
                    },
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
                  _showRateDialog(context, item);
                },
              ),

            const SizedBox(height: 16),
            if (item.myFeedback != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.myFeedback.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      onPressed: () {
                        ReusableComponents.deleteDialog<Manager>(
                          context,
                          () async {
                            _manager?.deleteSessionFeedback(item.id.toString());
                          },
                        );
                      },
                    ),
                  ],
                ),
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
                icon: const Icon(Icons.edit),
                label: const Text("Add Feedback"),
                onPressed: () {
                  _showFeedbackDialog(context, item);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showRateDialog(BuildContext context, SessionsModel item) {
    int tempRate = item.rate!.round();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xff2a2a2a),
        title: const Text(
          "Rate Session",
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
              _manager?.updateSessionRate({
                'sessionId': item.id,
                'rate': tempRate,
              });
            },
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context, SessionsModel item) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xff2a2a2a),
        title: const Text(
          "Add Feedback",
          style: TextStyle(color: Colors.greenAccent),
        ),
        content: TextField(
          controller: controller,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Write your feedback...",
            hintStyle: const TextStyle(color: Colors.white54),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
            child: const Text("Submit"),
            onPressed: () async {
              _manager?.addSessionFeedback({
                'sessionId': item.id,
                'feedback': controller.text,
              });
            },
          ),
        ],
      ),
    );
  }
}
