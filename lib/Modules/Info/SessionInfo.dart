import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gms_flutter/Models/SessionsModel.dart';
import 'package:gms_flutter/Shared/Components.dart';
import 'package:gms_flutter/Shared/Constant.dart';

class SessionInfo extends StatelessWidget {
  final SessionsModel sessionsModel;

  const SessionInfo({super.key, required this.sessionsModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.scaffoldColor,
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
            value:
                "${sessionsModel.subscribersCount} / ${sessionsModel.maxNumber}",
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: FontAwesomeIcons.dumbbell,
            title: "Class",
            value: sessionsModel.className ?? 'none',
          ),
          const SizedBox(height: 16),
          _buildScheduleCard(),
          const SizedBox(height: 16),
          _buildDescriptionCard(),
        ],
      ),
    );
  }

  Widget _buildClassBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Center(
        child: Stack(
          alignment: AlignmentGeometry.center,
          children: [
            (sessionsModel.classImage != null)
                ? Image.network(
                    Constant.mediaURL + sessionsModel.classImage.toString(),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.fitness_center, size: 100),
                  )
                : const Icon(Icons.image_not_supported_outlined, size: 100),
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withAlpha(155), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: Text(
                sessionsModel.title ?? 'none',
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
        ),
      ),
    );
  }

  Widget _buildCoachCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.teal.withAlpha(38),
            child: ClipOval(
              child: (sessionsModel.coach.profileImagePath != null)
                  ? Image.network(
                      Constant.mediaURL +
                          sessionsModel.coach.profileImagePath.toString(),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        color: Colors.greenAccent,
                        size: 40,
                      ),
                    )
                  : const Icon(
                      Icons.person,
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
                      '${sessionsModel.coach.firstName} ${sessionsModel.coach.lastName}',
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
            sessionsModel.description ?? '',
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
          ...sessionsModel.days.map((s) {
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
                    "${s.day} → ${s.startTime} - ${s.endTime}",
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
