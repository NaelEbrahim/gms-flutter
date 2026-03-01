import 'package:flutter/material.dart';
import 'package:gms_flutter/Models/ProfileModel.dart';
import 'package:gms_flutter/Shared/Constant.dart';
import 'package:gms_flutter/Shared/Components.dart';

class UserInfo extends StatelessWidget {
  final UserModel user;

  const UserInfo({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.scaffoldColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: reusableText(
          content: 'User Info',
          fontSize: 22,
          fontColor: Colors.greenAccent,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.9, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
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
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: user.profileImagePath != null
                        ? NetworkImage(
                            Constant.mediaURL + user.profileImagePath!,
                          )
                        : null,
                    child: user.profileImagePath == null
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                  const SizedBox(height: 20),
                  _infoRow("First Name", user.firstName),
                  _infoRow("Last Name", user.lastName),
                  _infoRow("Email", user.email),
                  _infoRow("Phone", user.phoneNumber),
                  _infoRow("Gender", user.gender),
                  _infoRow("Date of Birth", user.dob),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value ?? "-",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
