import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gms_flutter/BLoC/ChatManager.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Models/ChattingModel.dart';
import 'package:gms_flutter/Models/ProfileModel.dart';
import 'package:gms_flutter/Modules/Chatting/ChatDetail.dart';
import 'package:gms_flutter/Modules/Chatting/ChatList.dart';

import '../../Shared/Constant.dart';

class CoachesList extends StatelessWidget {
  const CoachesList({super.key});

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
          final cubit = ChatManager.get(context);
          if (cubit.coaches.isEmpty &&
              !cubit.isLoadingCoaches &&
              cubit.hasMoreCoaches) {
            cubit.getCoaches();
          }
          return ConditionalBuilder(
            condition: state is! LoadingState,
            builder: (_) => ListView.separated(
              itemCount: cubit.coaches.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (_, index) =>
                  _coachCard(context, cubit.coaches[index], cubit),
            ),
            fallback: (_) => const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _coachCard(
    BuildContext context,
    ProfileDataModel coach,
    ChatManager cubit,
  ) {
    return GestureDetector(
      onTap: () {
        final navigator = Navigator.of(context);
        // Capture bloc BEFORE navigation
        final chatManager = BlocProvider.of<ChatManager>(context);
        // check if this user already has a conversation
        var conversationId = '-1';
        final index = cubit.userConversations.indexWhere(
          (chat) => chat.otherUserId == coach.id.toString(),
        );
        if (index != -1) {
          conversationId = cubit.userConversations[index].id;
        }

        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: chatManager, // ← use captured bloc
              child: ChatDetail(
                ConversationModel(
                  id: conversationId,
                  otherUserId: coach.id.toString(),
                  otherUserName: '${coach.firstName} ${coach.lastName}',
                  otherUserProfileImage: coach.profileImagePath,
                ),
              ),
            ),
          ),
        );
      },
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Constant.scaffoldColor,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade100, width: 1.0),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.teal.withOpacity(0.15),
              child: ClipOval(
                child: Image.network(
                  Constant.mediaURL + coach.profileImagePath.toString(),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Icon(
                    FontAwesomeIcons.circleUser,
                    color: Colors.teal.shade700,
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
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.teal,
                    ),
                    child: Text(
                      'Body building',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 30, color: Colors.white),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
