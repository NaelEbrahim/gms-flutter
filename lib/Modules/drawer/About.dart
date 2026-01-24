import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../BLoC/Manager.dart';
import '../../BLoC/States.dart';
import '../../Shared/Components.dart';
import '../../Shared/Constant.dart';

class About extends StatelessWidget {
  About({super.key});

  final List<Map<String, String>> teamMembers = [
    {
      "name": "Nael Ebrahim",
      "role": "Lead Developer",
      "image": "images/team1.jpg",
    },
    {
      "name": "Sarah Lee",
      "role": "UI/UX Designer",
      "image": "images/team2.jpg",
    },
    {
      "name": "John Smith",
      "role": "Fitness Expert",
      "image": "images/team3.jpg",
    },
    {
      "name": "Emily Davis",
      "role": "Nutritionist",
      "image": "images/team4.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    var manager = Manager.get(context);
    manager.getAboutUs();
    return BlocConsumer<Manager, BLoCStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var item = manager.aboutUsModel;
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
          body: ConditionalBuilder(
              condition: state is! LoadingState,
              builder: (context) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // --- Header ---
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.teal.shade700,
                          child: Image.asset(
                            'images/logo_white.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item!.gymName,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent,
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

                    // --- Mission & Vision ---
                    _buildInfoCard(
                      icon: FontAwesomeIcons.bullseye,
                      title: "Our Mission",
                      description:
                      item.ourMission,
                    ),
                    const SizedBox(height: 20),
                    _buildInfoCard(
                      icon: FontAwesomeIcons.eye,
                      title: "Our Vision",
                      description:
                      item.ourVision,
                    ),

                    const SizedBox(height: 28),

                    // --- Team Section ---
                    // Team Section
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Meet the Team",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 160, // fixed height for horizontal cards
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: teamMembers.length,
                        separatorBuilder: (context, _) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final member = teamMembers[index];
                          return _buildTeamMemberHorizontal(
                            name: member['name']!,
                            role: member['role']!,
                            image: member['image']!,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),

                    // --- Follow Us ---
                    _buildFollowUsCard(),
                  ],
                ),
              ),
              fallback: (context) => Center(child: const CircularProgressIndicator(),),
          ),
        );
      },
    );
  }

  // Info Card
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
        border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.greenAccent, size: 36),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.greenAccent,
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

  // Team Member Card (list item with FontAwesome icon)
  Widget _buildTeamMemberHorizontal({
    required String name,
    required String role,
    required String image,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.black54,
        border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(
              image,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.person, size: 70, color: Colors.greenAccent),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            role,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Follow Us Card
  Widget _buildFollowUsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.teal.shade500, Constant.scaffoldColor],
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
