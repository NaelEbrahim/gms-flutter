import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Models/ProgramModel.dart';
import 'package:gms_flutter/Modules/Dashboard/Helper/ProgramDays.dart';
import 'package:gms_flutter/Shared/Components.dart';
import 'package:gms_flutter/Shared/Constant.dart';
import 'package:gms_flutter/Shared/SharedPrefHelper.dart';

import '../../BLoC/Manager.dart';

class MyPrograms extends StatefulWidget {
  const MyPrograms({super.key});

  @override
  State<MyPrograms> createState() => _MyProgramsState();
}

class _MyProgramsState extends State<MyPrograms> {
  late Manager manager;
  final TextEditingController feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    manager = Manager.get(context);
    manager.getUserPrograms();
  }

  @override
  void dispose() {
    manager.userPrograms.clear();
    feedbackController.dispose();
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
            title: reusableText(
              content: 'My Programs',
              fontSize: 22,
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
              if (state is SuccessState || state is UpdateNewState) {
                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: manager.userPrograms.length,
                  itemBuilder: (context, index) {
                    final item = manager.userPrograms[index];
                    return _buildProgramCard(context, item, index);
                  },
                );
              } else {
                return _errorWidget();
              }
            },
            fallback: (_) => const Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }

  Widget _buildProgramCard(BuildContext context, ProgramModel item, int index) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(item.id),
      tween: Tween(begin: 0.85, end: 1),
      duration: Duration(milliseconds: 500 + (index * 150)),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProgramDays(program: item)),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.fitness_center, color: Colors.greenAccent),
                    const SizedBox(width: 8),
                    Text(
                      item.level ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      item.isPublic == true ? Icons.public : Icons.lock_outline,
                      color: item.isPublic == true
                          ? Colors.greenAccent
                          : Colors.redAccent,
                    ),
                  ],
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
                        onPressed: () => _showRateDialog(context, item),
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
                    onPressed: () => _showRateDialog(context, item),
                  ),
                const SizedBox(height: 16),
                if (item.feedbacks!.isNotEmpty)
                  _feedbackBox(item)
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
                    onPressed: () => _showFeedbackDialog(context, item),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _feedbackBox(ProgramModel item) {
    return Container(
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
              item.feedbacks?.elementAt(0)['feedback'] ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
            onPressed: () {
              ReusableComponents.deleteDialog<Manager>(context, () async {
                manager.deleteProgramFeedback({
                  'userId': SharedPrefHelper.getString('id'),
                  'programId': item.id,
                });
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _errorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          reusableText(
            content: 'Connection error!',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => manager.getUserPrograms(),
            child: Container(
              height: 50,
              width: Constant.screenWidth / 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade700, Constant.scaffoldColor],
                ),
                borderRadius: BorderRadius.circular(15),
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

  void _showRateDialog(BuildContext context, ProgramModel item) {
    int tempRate = item.rate?.round() ?? 0;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xff2a2a2a),
        title: const Text(
          "Rate Program",
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
                  onPressed: () => setDialogState(() => tempRate = i),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              manager.updateProgramRate({
                'programId': item.id,
                'rate': tempRate,
              });
              Navigator.pop(dialogContext);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context, ProgramModel item) {
    feedbackController.clear();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xff2a2a2a),
        title: const Text(
          "Add Feedback",
          style: TextStyle(color: Colors.greenAccent),
        ),
        content: TextField(
          controller: feedbackController,
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              manager.addProgramFeedback({
                'programId': item.id,
                'feedback': feedbackController.text,
              });
              Navigator.pop(dialogContext);
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
