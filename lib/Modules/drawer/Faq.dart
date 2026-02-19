import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Shared/Constant.dart';

import '../../BLoC/Manager.dart';
import '../../Shared/Components.dart';

class FAQ extends StatefulWidget {
  const FAQ({super.key});

  @override
  State<FAQ> createState() => _FAQState();
}

class _FAQState extends State<FAQ> {
  late Manager manager;

  @override
  void initState() {
    super.initState();
    manager = Manager.get(context);
    manager.getFAQs();
  }

  @override
  void dispose() {
    manager.faqList.clear();
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
              content: 'FAQ',
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
                if (manager.faqList.isNotEmpty) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: manager.faqList.length,
                    itemBuilder: (context, index) {
                      final faq = manager.faqList[index];
                      return _buildFAQCard(
                        question: faq.question,
                        answer: faq.answer,
                        index: index,
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text(
                      "No FAQs yet.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  );
                }
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
                          manager.getFAQs();
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

  Widget _buildFAQCard({
    required String question,
    required String answer,
    required int index,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + index * 120),
      tween: Tween(begin: 0.9, end: 1),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Theme(
          data: ThemeData.dark().copyWith(
            dividerColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.greenAccent),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            childrenPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: const Icon(
              FontAwesomeIcons.circleQuestion,
              color: Colors.greenAccent,
            ),
            title: Text(
              question,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  answer,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
