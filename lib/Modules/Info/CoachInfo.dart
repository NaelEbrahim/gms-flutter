import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gms_flutter/Shared/Components.dart';

class CoachInfoScreen extends StatelessWidget {
  final String coachName;
  final String coachImage;
  final String specialization;
  final String bio;
  final double rating;
  final int classes;
  final int sessions;
  final int subscribers;
  final int dietPlans;
  final int privateTrainings;

  const CoachInfoScreen({
    super.key,
    required this.coachName,
    required this.coachImage,
    required this.specialization,
    required this.bio,
    required this.rating,
    required this.classes,
    required this.sessions,
    required this.subscribers,
    required this.dietPlans,
    required this.privateTrainings,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff212121),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: reusableText(
          content: 'Coach Info',
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
          _buildHeader(),
          const SizedBox(height: 20),
          _buildStatsCard(),
          const SizedBox(height: 16),
          _buildOfferingsCard(),
          const SizedBox(height: 20),
          _buildBioCard(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: Image.asset(
              coachImage,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                FontAwesomeIcons.userTie,
                size: 60,
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
                  coachName,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  specialization,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating.round() ? Icons.star : Icons.star_border,
                      color: Colors.greenAccent,
                      size: 18,
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: _cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(FontAwesomeIcons.dumbbell, "$classes", "Classes"),
          _buildStatItem(
            FontAwesomeIcons.calendarDays,
            "$sessions",
            "Sessions",
          ),
        ],
      ),
    );
  }

  Widget _buildOfferingsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: _cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            FontAwesomeIcons.personRunning,
            "$privateTrainings",
            "Private Training",
          ),
          _buildStatItem(FontAwesomeIcons.utensils, "$dietPlans", "Diet Plans"),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.greenAccent, size: 26),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.greenAccent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildBioCard() {
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
                "About Coach",
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(bio, style: const TextStyle(color: Colors.white70, height: 1.4)),
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
