import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gms_flutter/BLoC/Manager.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Modules/ChangePassword.dart';
import 'package:gms_flutter/Modules/Login.dart';
import 'package:gms_flutter/Shared/Constant.dart';
import 'package:gms_flutter/Shared/SharedPrefHelper.dart';

import '../../Shared/Components.dart';

class Settings extends StatelessWidget {
  Settings({super.key});

  Manager? _manager;

  final String appVersion = "1.0.0";

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: Manager.get(context),
      child: BlocConsumer<Manager, BLoCStates>(
        listener: (context, state) {},
        builder: (context, state) {
          _manager = Manager.get(context);
          return Scaffold(
            backgroundColor: Constant.scaffoldColor,
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.white),
              title: reusableText(
                content: 'Settings',
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
                // Account Section
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.9, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: _buildSectionCard(
                    title: "Account",
                    icon: FontAwesomeIcons.user,
                    children: [
                      _buildOptionTile(
                        icon: FontAwesomeIcons.userPen,
                        title: "Edit Profile",
                        onTap: () {},
                      ),
                      _buildOptionTile(
                        icon: FontAwesomeIcons.key,
                        title: "Change Password",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangePassword(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.9, end: 1),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: _buildSectionCard(
                    title: "Preferences",
                    icon: FontAwesomeIcons.sliders,
                    children: [
                      _buildToggleTile(
                        icon: FontAwesomeIcons.moon,
                        title: "Dark Mode",
                        value: SharedPrefHelper.getBool('appTheme') ?? false,
                        onChanged: (val) {
                          _manager!.changeAppTheme();
                          _manager!.updateState();
                        },
                      ),
                      _buildToggleTile(
                        icon: FontAwesomeIcons.bell,
                        title: "Notifications",
                        value:
                            SharedPrefHelper.getBool('appNotifications') ??
                            false,
                        onChanged: (val) {
                          _manager!.changeAppNotification();
                          _manager!.updateState();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // About Section
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.9, end: 1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: _buildSectionCard(
                    title: "About",
                    icon: FontAwesomeIcons.infoCircle,
                    children: [
                      _buildOptionTile(
                        icon: FontAwesomeIcons.fileCircleQuestion,
                        title: "FAQ",
                        onTap: () {},
                      ),
                      _buildAppVersionTile(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Logout Button
                ConditionalBuilder(
                  condition: state is! LoadingState,
                  builder: (context) => ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(FontAwesomeIcons.rightFromBracket),
                    label: const Text("Logout", style: TextStyle(fontSize: 16)),
                    onPressed: () {
                      _manager!.logout();
                    },
                  ),
                  fallback: (context) =>
                      Center(child: const CircularProgressIndicator()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
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
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.greenAccent),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Divider(color: Colors.white),
          //const SizedBox(height: 12),
          ...children.map((child) => Column(children: [child])),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        leading: Icon(icon, color: Colors.greenAccent),
        title: Text(title, style: const TextStyle(color: Colors.white70)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white38,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        leading: Icon(icon, color: Colors.greenAccent),
        title: Text(title, style: const TextStyle(color: Colors.white70)),
        trailing: Switch(
          value: value,
          activeColor: Colors.greenAccent,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildAppVersionTile() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: const Icon(FontAwesomeIcons.mobile, color: Colors.greenAccent),
      title: const Text("App Version", style: TextStyle(color: Colors.white70)),
      trailing: Text(appVersion, style: const TextStyle(color: Colors.white54)),
    );
  }
}
