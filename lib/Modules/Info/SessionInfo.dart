import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gms_flutter/Models/ProfileModel.dart';
import 'package:gms_flutter/Shared/Components.dart';

class SessionInfo extends StatelessWidget {
  final String title;
  final ProfileDataModel coach;
  final String className;
  final String classImage;
  final String description;
  final String startTime;
  final String endTime;
  final int subscribers;
  final List<String> schedule;

  const SessionInfo({
    super.key,
    required this.title,
    required this.coach,
    required this.className,
    required this.classImage,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.subscribers,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff212121),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: reusableText(
          content: 'Session Info',
          fontSize: 22.0,
          fontColor: Colors.greenAccent,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildClassBanner(),

          const SizedBox(height: 20),
          _buildCoachCard(),

          const SizedBox(height: 16),
          _buildInfoCard(
            icon: FontAwesomeIcons.users,
            title: "Subscribers",
            value: "$subscribers people joined",
          ),

          const SizedBox(height: 16),
          _buildInfoCard(
            icon: FontAwesomeIcons.dumbbell,
            title: "Class",
            value: className,
          ),

          const SizedBox(height: 16),
          _buildDescriptionCard(),

          const SizedBox(height: 16),
          _buildScheduleCard(),
        ],
      ),
    );
  }

  Widget _buildClassBanner() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'images/session.jpg',
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 180,
              color: Colors.grey.shade800,
              child: const Icon(
                FontAwesomeIcons.dumbbell,
                color: Colors.greenAccent,
                size: 50,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black87,
                  offset: Offset(1, 1),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoachCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.asset(
              coach.profileImagePath.toString(),
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                FontAwesomeIcons.userTie,
                color: Colors.greenAccent,
                size: 40,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Audit Coach',
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.chalkboardUser,
                      size: 16,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${coach.firstName} ${coach.lastName}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Icon(icon, color: Colors.greenAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(FontAwesomeIcons.circleInfo, color: Colors.greenAccent),
              SizedBox(width: 8),
              Text(
                "Description",
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(FontAwesomeIcons.calendarDays, color: Colors.greenAccent),
              SizedBox(width: 8),
              Text(
                "Schedule",
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...schedule.map((s) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(
                    FontAwesomeIcons.solidClock,
                    size: 16,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "$s → $startTime - $endTime",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: LinearGradient(
        colors: [Colors.teal.shade700, Colors.black87],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(76),
          blurRadius: 8,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }
}
