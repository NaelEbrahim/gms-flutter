import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Modules/Chatting/CoachesList.dart';
import 'package:intl/intl.dart';

import '../../BLoC/ChatManager.dart';
import '../../Remote/Pusher_Linker.dart';
import '../../Shared/Components.dart';
import '../../Shared/Constant.dart';
import 'ChatDetail.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    ChatManager manager;
    return BlocProvider(
      create: (context) => ChatManager()..getUserConversations(),
      child: BlocConsumer<ChatManager, BLoCStates>(
        listener: (context, state) {
          if (state is ErrorState) {
            ReusableComponents.showToast(
              state.error.toString(),
              background: Colors.red,
            );
          }
        },
        builder: (blocContext, state) {
          manager = ChatManager.get(blocContext);
          final chats = manager.userConversations;
          return PopScope(
            canPop: true,
            onPopInvokedWithResult: (didPop, result) {
              manager.clearConversations();
            },
            child: Scaffold(
              backgroundColor: Constant.scaffoldColor,
              appBar: AppBar(
                title: const Text(
                  'ShapeUp Chats',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 22.0,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.more_vert_outlined),
                  ),
                ],
                backgroundColor: Colors.black,
                elevation: 1,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    blocContext,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: BlocProvider.of<ChatManager>(blocContext),
                        child: CoachesList(),
                      ),
                    ),
                  );
                },
                backgroundColor: Colors.teal,
                child: Icon(
                  FontAwesomeIcons.solidSquarePlus,
                  color: Colors.black,
                ),
              ),
              body: Center(
                child: ConditionalBuilder(
                  condition: state is! LoadingState,
                  builder: (context) {
                    if (state is SuccessState || state is UpdateNewState) {
                      if (chats.isNotEmpty) {
                        return ListView.builder(
                          itemCount: chats.length,
                          itemBuilder: (context, index) {
                            final chat = chats.elementAt(index);
                            return Container(
                              decoration: BoxDecoration(
                                color: Constant.scaffoldColor,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade100,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 8,
                                ),
                                leading: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.teal.withOpacity(
                                    0.15,
                                  ),
                                  child: ClipOval(
                                    child:
                                        (chat.otherUserProfileImage != null &&
                                            chat.otherUserProfileImage.toString() != 'null')
                                        ? Image.network(
                                            Constant.mediaURL + chat.otherUserProfileImage.toString(),
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) => Icon(
                                              FontAwesomeIcons.circleUser,
                                              color: Colors.teal.shade700,
                                              size: 32,
                                            ),
                                          )
                                        : Icon(
                                            FontAwesomeIcons.circleUser,
                                            color: Colors.teal.shade700,
                                            size: 32,
                                          ),
                                  ),
                                ),
                                title: Text(
                                  chat.otherUserName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                    color: Colors.white,
                                  ),
                                ),
                                onLongPress: () {
                                  ReusableComponents.deleteDialog<ChatManager>(
                                    blocContext,
                                    () async {
                                      manager.deleteConversation({
                                        'channel_name':
                                            Pusher_Linker.getChannelName(),
                                        'conversationId': chat.id,
                                      });
                                    },
                                    title: 'Delete this chat?',
                                  );
                                },
                                subtitle: Text(
                                  chat.lastMessageType == 'TEXT'
                                      ? chat.lastMessage ?? ""
                                      : chat.lastMessageType ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      formatChatTime(
                                        ReusableComponents.formatDateTime(
                                          chat.lastMessageTime ?? "",
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    if (int.parse(chat.unreadCount ?? "0") > 0)
                                      Container(
                                        margin: const EdgeInsets.only(top: 6),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.teal.shade400,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          chat.unreadCount.toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    blocContext,
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: BlocProvider.of<ChatManager>(
                                          blocContext,
                                        ),
                                        child: ChatDetail(chat),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      } else {
                        return reusableText(
                          content:
                              'no Chats Yet \n press + below to create new one!',
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          maxLines: 3,
                        );
                      }
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          reusableText(
                            content: 'Connection error!',
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                          const SizedBox(height: 10.0),
                          GestureDetector(
                            onTap: () {
                              manager.getUserConversations();
                            },
                            child: Container(
                              height: 50,
                              width: Constant.screenWidth / 3,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.teal.shade700,
                                    Constant.scaffoldColor,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.shade700,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  "Retry",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                  fallback: (context) => const CircularProgressIndicator(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String formatChatTime(String dateString) {
    try {
      final date = DateFormat("yyyy/MM/dd HH:mm").parse(dateString);
      final now = DateTime.now();
      final isToday =
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
      if (isToday) {
        return DateFormat('hh:mm a').format(date);
      } else {
        return DateFormat('yy/MM/dd').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }
}
