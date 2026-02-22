import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gms_flutter/BLoC/ChatManager.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Models/ChattingModel.dart';
import 'package:gms_flutter/Models/ProfileModel.dart';
import 'package:gms_flutter/Modules/Chatting/ChatDetail.dart';
import 'package:gms_flutter/Shared/SharedPrefHelper.dart';

import '../../Shared/Constant.dart';

class CoachesList extends StatefulWidget {
  const CoachesList({super.key});

  @override
  State<CoachesList> createState() => _CoachesListState();
}

class _CoachesListState extends State<CoachesList> {
  late ChatManager chatManager;

  @override
  void initState() {
    super.initState();
    chatManager = ChatManager.get(context);
    chatManager.getCoaches();
  }

  @override
  void dispose() {
    chatManager.coaches.items.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.scaffoldColor,
      appBar: AppBar(
        title: const Text(
          'ShapeUp Coaches',
          style: TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_outlined),
          ),
        ],
        backgroundColor: Colors.black,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<ChatManager, BLoCStates>(
        listener: (_, _) {},
        builder: (context, state) {
          return ConditionalBuilder(
            condition: state is! LoadingState,
            builder: (_) => ListView.separated(
              padding: EdgeInsets.all(10),
              itemCount: chatManager.coaches.items.length,
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (_, _) => const SizedBox(height: 25),
              itemBuilder: (_, index) =>
                  _coachCard(context, chatManager.coaches.items[index]),
            ),
            fallback: (_) => const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _coachCard(BuildContext context, UserModel coach) {
    if (coach.id.toString() == SharedPrefHelper.getString('id')) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTap: () {
        final navigator = Navigator.of(context);
        // check if this user already has a conversation
        var conversationId = '-1';
        final index = chatManager.userConversations.indexWhere(
          (chat) => chat.otherUserId == coach.id.toString(),
        );
        if (index != -1) {
          conversationId = chatManager.userConversations[index].id;
        }
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (_) => ChatDetail(
              ConversationModel(
                id: conversationId,
                otherUserId: coach.id.toString(),
                otherUserName: '${coach.firstName} ${coach.lastName}',
                otherUserProfileImage: coach.profileImagePath,
              ),
            ),
          ),
        );
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.teal.withAlpha(38),
            child: ClipOval(
              child: Image.network(
                Constant.mediaURL + coach.profileImagePath.toString(),
                width: 65,
                height: 65,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(
                  FontAwesomeIcons.circleUser,
                  color: Colors.teal,
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${coach.firstName} ${coach.lastName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 30, color: Colors.white),
        ],
      ),
    );
  }
}
