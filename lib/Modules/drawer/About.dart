import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../BLoC/Manager.dart';
import '../../BLoC/States.dart';
import '../../Shared/Components.dart';
import '../../Shared/Constant.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  late Manager manager;

  @override
  void initState() {
    super.initState();
    manager = Manager.get(context);
    manager.getAboutUs();
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
              content: 'About us',
              fontSize: 22.0,
              fontColor: Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: Colors.black,
            centerTitle: true,
            elevation: 0,
          ),
          body: SafeArea(
            child: ConditionalBuilder(
              condition: state is! LoadingState,
              builder: (context) {
                var item = manager.aboutUsModel;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Image.asset(
                            'images/logo.png',
                            height: Constant.screenHeight / 4,
                            width: Constant.screenHeight / 4,
                            fit: BoxFit.contain,
                          ),
                          Text(
                            item!.gymName,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.gymDescription,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildInfoCard(
                        icon: FontAwesomeIcons.bullseye,
                        title: "Our Mission",
                        description: item.ourMission,
                      ),
                      const SizedBox(height: 20),
                      _buildInfoCard(
                        icon: FontAwesomeIcons.eye,
                        title: "Our Vision",
                        description: item.ourVision,
                      ),
                      const SizedBox(height: 28),
                      _buildFollowUsCard(),
                    ],
                  ),
                );
              },
              fallback: (context) =>
                  Center(child: const CircularProgressIndicator()),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black54,
        border: Border.all(color: Colors.teal.withAlpha(76)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.teal, size: 36),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.teal,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.teal, Constant.scaffoldColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Text(
            "Follow us",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSocialButton(FontAwesomeIcons.squareFacebook, Colors.blue),
              _buildSocialButton(FontAwesomeIcons.instagram, Colors.pink),
              _buildSocialButton(FontAwesomeIcons.xTwitter, Colors.black),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return CircleAvatar(
      radius: 26,
      backgroundColor: Colors.white,
      child: Icon(icon, color: color, size: 26),
    );
  }
}
