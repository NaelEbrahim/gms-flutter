import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Modules/Home/Dashboard.dart';
import 'package:gms_flutter/Modules/Home/Home.dart';
import 'package:gms_flutter/Modules/Home/Profile.dart';
import 'package:gms_flutter/Modules/Home/ShowQR.dart';
import 'package:gms_flutter/Modules/drawer/About.dart';
import 'package:gms_flutter/Modules/drawer/Faq.dart';
import 'package:gms_flutter/Modules/drawer/KnowledgeHub/KnowledgeHubHome.dart';
import 'package:gms_flutter/Modules/drawer/Settings.dart';
import 'package:gms_flutter/Modules/drawer/SubscriptionsHistory.dart';
import 'package:gms_flutter/Shared/Components.dart';
import 'package:gms_flutter/Shared/Constant.dart';
import '../BLoC/Manager.dart';
import 'Chatting/ChatList.dart';
import 'Notifications.dart';

typedef DrawerItemCallback = void Function(String routeName);

class Base extends StatelessWidget {
  Base({super.key});

  int bottomNavIndex = 0;

  List<Widget> screens = [Home(), Dashboard(), ShowQR(), Profile()];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var manager = Manager.get(context);
    manager.getUserProfile();
    return BlocConsumer<Manager, BLoCStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: buildDrawer(context),
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              icon: Icon(Icons.menu, color: Colors.white),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Notifications()),
                  );
                },
                icon: Icon(Icons.notifications, color: Colors.white),
              ),
            ],
            backgroundColor: Colors.black,
            centerTitle: true,
            title: reusableText(
              content: 'ShapeUp',
              fontSize: 22.0,
              fontColor: Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          body: SafeArea(
            child: Container(
              height: Constant.screenHeight,
              width: Constant.screenWidth,
              padding: const EdgeInsets.only(
                top: 5.0,
                left: 10.0,
                right: 10.0,
              ),
              color: Colors.black87,
              child: screens[bottomNavIndex],
            ),
          ),
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(canvasColor: Colors.black),
            child: BottomNavigationBar(
              currentIndex: bottomNavIndex,
              onTap: (int index) {
                bottomNavIndex = index;
                manager.updateState();
              },
              selectedItemColor: Colors.greenAccent,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.house_outlined),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.track_changes_outlined),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code_2_outlined),
                  label: 'QR',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.23,
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 18.0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade700, Constant.scaffoldColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(76),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 47,
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      'images/logo_white.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ShapeUp',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Knowledge & Member tools',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.black87,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _tile(
                      context,
                      Icons.chat_bubble_outline,
                      "Chats",
                      ChatList(),
                    ),
                    _tile(
                      context,
                      Icons.history,
                      "Subscription History",
                      SubscriptionHistory(),
                    ),
                    _tile(
                      context,
                      Icons.menu_book_outlined,
                      "Knowledge Hub",
                      KnowledgeHubHome(),
                    ),
                    _tile(
                      context,
                      Icons.settings_outlined,
                      "Settings",
                      Settings(),
                    ),
                    const Divider(),
                    _tile(
                      context,
                      Icons.info_outline,
                      "About Us",
                      About(),
                      trailingArrow: false,
                    ),
                    _tile(
                      context,
                      Icons.help_outline,
                      "FAQ",
                      FAQ(),
                      trailingArrow: false,
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

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    Widget route, {
    bool trailingArrow = true,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.greenAccent),
      title: reusableText(
        content: title,
        fontWeight: FontWeight.w400,
        fontColor: Colors.white,
        textAlign: TextAlign.start,
        fontSize: 15.0,
      ),
      trailing: trailingArrow
          ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70)
          : null,
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => route));
      },
    );
  }
}
