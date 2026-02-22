import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Models/ChattingModel.dart';
import 'package:gms_flutter/Shared/Components.dart';
import 'package:gms_flutter/Shared/Constant.dart';
import 'package:gms_flutter/Shared/SharedPrefHelper.dart';
import 'package:image_picker/image_picker.dart';
import '../../BLoC/ChatManager.dart';
import '../../Remote/Pusher_Linker.dart';
import 'MessageBubble.dart';

final TextEditingController _controller = TextEditingController();

class ChatDetail extends StatelessWidget {
  final ConversationModel chatInfo;
  final ScrollController _scrollController = ScrollController();

  ChatDetail(this.chatInfo, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatManager, BLoCStates>(
      listener: (context, state) {},
      builder: (context, state) {
        ChatManager manager = ChatManager.get(context);
        if (chatInfo.id != '-1') {
          manager.getConversationsMessages(chatInfo.id);
        }
        String channelName = Pusher_Linker.getChannelName();
        var chat = manager.userConversationMessages;
        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            manager.clearChatMessages();
            manager.updateConversationLastSeen(chatInfo.id);
          },
          child: Scaffold(
            appBar: (!manager.chatSelectionMode)
                ? AppBar(
                    backgroundColor: Colors.black,
                    iconTheme: const IconThemeData(color: Colors.white),
                    leading: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 5.0),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.teal.withOpacity(0.15),
                          child: ClipOval(
                            child:
                                (chatInfo.otherUserProfileImage != null &&
                                    chatInfo.otherUserProfileImage.toString() !=
                                        'null')
                                ? Image.network(
                                    Constant.mediaURL +
                                        chatInfo.otherUserProfileImage
                                            .toString(),
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
                        const SizedBox(width: 10.0),
                        Text(
                          chatInfo.otherUserName,
                          style: const TextStyle(
                            color: Colors.teal,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    leadingWidth: double.infinity,
                    actions: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.more_vert_outlined),
                      ),
                    ],
                  )
                : AppBar(
                    backgroundColor: Colors.black,
                    title: Text(
                      '${manager.selectedMessages.length} selected',
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    leading: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        manager.selectedMessages.clear();
                        manager.changeChatSelectionMode();
                      },
                    ),
                    actions: _buildAppBarActions(context, manager, channelName),
                  ),
            body: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('images/chat_BG.jpg'),
                    fit: BoxFit.cover,
                    repeat: ImageRepeat.repeat,
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (scrollNotification) {
                          if (scrollNotification is ScrollEndNotification) {
                            final metrics = scrollNotification.metrics;
                            final reachedTop =
                                metrics.pixels >=
                                (metrics.maxScrollExtent - 10);
                            if (reachedTop) {
                              if (!manager.isLoadingMessages &&
                                  manager.hasMoreMessages) {
                                manager.getConversationsMessages(chatInfo.id);
                              }
                            }
                          }
                          return false;
                        },
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            ListView.builder(
                              reverse: true,
                              controller: _scrollController,
                              itemCount: chat.length,
                              itemBuilder: (context, index) {
                                final message = chat.elementAt(index);
                                final isMe =
                                    message.sender.id ==
                                    int.parse(
                                      SharedPrefHelper.getString(
                                        'id',
                                      ).toString(),
                                    );
                                String? dateHeader;
                                if (index == chat.length - 1) {
                                  // First message in the list
                                  dateHeader = formatDate(message.date);
                                } else {
                                  final previousMessage = chat[index + 1];
                                  if (!isSameDay(
                                    message.date,
                                    previousMessage.date,
                                  )) {
                                    dateHeader = formatDate(message.date);
                                  }
                                }
                                return Column(
                                  children: [
                                    if (dateHeader != null)
                                      Center(
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            dateHeader,
                                            style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    GestureDetector(
                                      onLongPress: () {
                                        if (!manager.chatSelectionMode) {
                                          manager.selectedMessages.add(message);
                                          manager.changeChatSelectionMode();
                                        }
                                      },
                                      onTap: () {
                                        if (manager.chatSelectionMode) {
                                          if (manager.selectedMessages.contains(
                                            message,
                                          )) {
                                            manager.selectedMessages.remove(
                                              message,
                                            );
                                            if (manager
                                                .selectedMessages
                                                .isEmpty) {
                                              manager.changeChatSelectionMode();
                                            }
                                          } else {
                                            manager.selectedMessages.add(
                                              message,
                                            );
                                          }
                                          manager.updateState();
                                        }
                                      },
                                      child: Stack(
                                        children: [
                                          MessageBubble(
                                            content: message.content,
                                            type: message.type,
                                            isMe: isMe,
                                            time: message.date,
                                            status: (isMe)
                                                ? message.status
                                                : null,
                                          ),
                                          if (manager.selectedMessages.contains(
                                            message,
                                          ))
                                            Positioned.fill(
                                              child: Container(
                                                color: Colors.teal.withOpacity(
                                                  0.3,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            if (chatInfo.id == '-1' && chat.isEmpty) ...[
                              Center(
                                child: Image.asset(
                                  'images/noMessages_dark.png',
                                ),
                              ),
                            ],
                            if (state is LoadingState) ...[
                              Positioned(
                                top: 10,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    _buildMessageInput(manager, context, channelName),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput(
    ChatManager manager,
    BuildContext context,
    String channelName,
  ) {
    final focusNode = FocusNode();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Material(
                  elevation: 10,
                  borderRadius: BorderRadius.circular(20.0),
                  shadowColor: Colors.black12,
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            manager.emojiVisible
                                ? Icons.keyboard
                                : Icons.emoji_emotions_outlined,
                            color: Colors.teal.shade700,
                          ),
                          onPressed: () async {
                            if (!manager.emojiVisible) {
                              FocusScope.of(context).unfocus();
                              await SystemChannels.textInput.invokeMethod(
                                'TextInput.hide',
                              );
                              await Future.delayed(
                                const Duration(milliseconds: 100),
                              );
                            } else {
                              focusNode.requestFocus();
                            }
                            manager.changeChatEmojiVisible();
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: focusNode,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'Message...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                            ),
                            onTap: () {
                              if (manager.emojiVisible) {
                                manager.changeChatEmojiVisible();
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.camera_alt,
                            color: Colors.teal.shade700,
                          ),
                          onPressed: () async {
                            final XFile? image =
                                await ReusableComponents.pickImage();
                            if (image != null) {
                              manager.sendFileMessage({
                                "channel_name": channelName,
                                "receiverId": chatInfo.otherUserId,
                                "messageType": 'IMAGE',
                              }, image);
                            }
                          },
                        ),
                        const SizedBox(width: 5),
                      ],
                    ),
                  ),
                ),
                Offstage(
                  offstage: !manager.emojiVisible,
                  child: SizedBox(
                    height: 250,
                    child: EmojiPicker(
                      textEditingController: _controller,
                      onBackspacePressed: () {
                        _controller
                          ..text = _controller.text.characters
                              .skipLast(1)
                              .toString()
                          ..selection = TextSelection.fromPosition(
                            TextPosition(offset: _controller.text.length),
                          );
                      },
                      config: Config(
                        height: 256,
                        checkPlatformCompatibility: true,
                        emojiViewConfig: EmojiViewConfig(
                          noRecents: const Text(
                            'No Recents',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                            // change color here
                            textAlign: TextAlign.center,
                          ),
                          backgroundColor: Constant.scaffoldColor,
                          columns: 7,
                          emojiSizeMax: 32,
                        ),
                        categoryViewConfig: CategoryViewConfig(
                          backgroundColor: Constant.scaffoldColor,
                          iconColorSelected: Colors.teal,
                          indicatorColor: Colors.teal,
                        ),
                        bottomActionBarConfig: BottomActionBarConfig(
                          backgroundColor: Constant.scaffoldColor,
                          buttonColor: Colors.teal,
                        ),
                        skinToneConfig: SkinToneConfig(),
                        searchViewConfig: SearchViewConfig(
                          backgroundColor: Constant.scaffoldColor,
                          buttonIconColor: Colors.white,
                          hintText: 'Search emoji...',
                          hintTextStyle: TextStyle(color: Colors.white),
                          inputTextStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5.0),
          InkWell(
            onTap: () {
              final text = _controller.text.trim();
              if (text.isNotEmpty) {
                manager.sendTextMessage({
                  "channel_name": channelName,
                  "receiverId": chatInfo.otherUserId,
                  "content": text,
                });
              }
              _controller.clear();
              Future.delayed(const Duration(milliseconds: 300), () {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.teal.shade700,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const FaIcon(
                FontAwesomeIcons.paperPlane,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAppBarActions(
    BuildContext context,
    ChatManager manager,
    String channelName,
  ) {
    bool hasImage = manager.selectedMessages.any((m) => m.type == 'IMAGE');
    bool hasText = manager.selectedMessages.any((m) => m.type == 'TEXT');
    int currentUserId = int.parse(SharedPrefHelper.getString('id') ?? "0");
    // Multiple selections → delete only
    if (manager.selectedMessages.length > 1) {
      bool sentByMe = true;
      for (Message item in manager.selectedMessages) {
        if (item.sender.id != currentUserId) {
          sentByMe = false;
        }
      }
      return [
        if (sentByMe)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              ReusableComponents.deleteDialog<ChatManager>(
                context,
                () async {
                  manager.deleteMessage({
                    "channel_name": channelName,
                    "messageIds": manager.selectedMessages
                        .map((m) => m.id)
                        .toList(),
                  });
                },
                title: "Delete messages?",
                body:
                    "Are you sure you want to delete these messages for everyone?",
              );
            },
          ),
      ];
    }
    // Single selection → delete & save or copy
    if (manager.selectedMessages.length == 1) {
      var selectedMessage = manager.selectedMessages.single;
      bool sentByMe = selectedMessage.sender.id == currentUserId;
      if (hasImage) {
        return [
          IconButton(
            icon: const Icon(Icons.save_alt, color: Colors.white),
            onPressed: () async {
              var isSaved = await ReusableComponents.saveImageToGallery(
                Constant.mediaURL + selectedMessage.content,
              );
              if (isSaved) {
                manager.selectedMessages.clear();
                manager.changeChatSelectionMode();
              }
            },
          ),
          if (sentByMe)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                ReusableComponents.deleteDialog<ChatManager>(
                  context,
                  () async {
                    manager.deleteMessage({
                      "channel_name": channelName,
                      "messageIds": manager.selectedMessages
                          .map((m) => m.id)
                          .toList(),
                    });
                  },
                  title: "Delete message?",
                  body:
                      "Are you sure you want to delete this message for everyone?",
                );
              },
            ),
        ];
      } else if (hasText) {
        return [
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white),
            onPressed: () {
              Clipboard.setData(
                ClipboardData(text: manager.selectedMessages.first.content),
              );
              manager.selectedMessages.clear();
              manager.changeChatSelectionMode();
            },
          ),
          if (sentByMe)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                ReusableComponents.deleteDialog<ChatManager>(
                  context,
                  () async {
                    manager.deleteMessage({
                      "channel_name": channelName,
                      "messageIds": manager.selectedMessages
                          .map((m) => m.id)
                          .toList(),
                    });
                  },
                  title: "Delete message?",
                  body:
                      "Are you sure you want to delete this message for everyone?",
                );
              },
            ),
        ];
      }
    }
    return [];
  }

  bool isSameDay(DateTime d1, DateTime d2) =>
      d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;

  String formatDate(DateTime date) {
    final now = DateTime.now();
    if (isSameDay(date, now)) return 'Today';
    if (isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}
