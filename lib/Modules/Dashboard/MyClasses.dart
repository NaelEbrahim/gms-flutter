import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Models/ClassesModel.dart';
import 'package:gms_flutter/Modules/Info/ClassInfo.dart';
import 'package:gms_flutter/Shared/Components.dart';
import 'package:gms_flutter/Shared/Constant.dart';

import '../../BLoC/Manager.dart';

class MyClasses extends StatefulWidget {
  const MyClasses({super.key});

  @override
  State<MyClasses> createState() => _MyClassesState();
}

class _MyClassesState extends State<MyClasses> {
  late Manager manager;

  @override
  void initState() {
    super.initState();
    manager = Manager.get(context);
    manager.getUserClasses();
  }

  @override
  void dispose() {
    manager.userClasses.clear();
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
            iconTheme: IconThemeData(color: Colors.white),
            title: reusableText(
              content: 'My Classes',
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
                  padding: const EdgeInsets.all(10),
                  itemCount: manager.userClasses.length,
                  itemBuilder: (context, index) {
                    ClassesModel? item = manager.userClasses.elementAt(index);
                    return _buildClassCard(context, item, index);
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
                          manager.getUserClasses();
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

  Widget _buildClassCard(BuildContext context, ClassesModel item, int index) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(item.id),
      tween: Tween(begin: 0.85, end: 1),
      duration: Duration(milliseconds: 500 + (index * 150)),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: GestureDetector(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClassInfo(
                classId: item.id.toString(),
                image: item.imagePath,
                title: item.name.toString(),
                description: item.description.toString(),
                pricePerMonth: item.price.toString(),
                coach: item.coach,
              ),
            ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: (item.imagePath != null) ? Image.network(
                    Constant.mediaURL + item.imagePath.toString(),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.fill,
                    errorBuilder: (_, _, _) =>
                    const Icon(Icons.broken_image, size: 100),
                  ) : const Icon(Icons.image_not_supported_outlined,size: 100,),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name.toString(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          item.isActive ? Icons.check_circle : Icons.cancel,
                          color: item.isActive
                              ? Colors.greenAccent
                              : Colors.redAccent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.isActive ? "Active" : "Inactive",
                          style: TextStyle(
                            color: item.isActive
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "Joined: ${item.joinedAt?.substring(0, 10)}",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (item.myFeedBack != null)
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
                                item.myFeedBack.toString(),
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
                                    manager.deleteClassFeedback(
                                      item.id.toString(),
                                    );
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
                        label: const Text("Submit Feedback"),
                        onPressed: () {
                          _showFeedbackDialog(context, item);
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context, ClassesModel item) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xff2a2a2a),
        title: const Text(
          "Submit Feedback",
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
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.black,
            ),
            child: const Text("Submit"),
            onPressed: () async {
              manager.addClassFeedback({
                'classId': item.id,
                'feedback': controller.text,
              });
            },
          ),
        ],
      ),
    );
  }
}
