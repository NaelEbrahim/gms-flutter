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

class ChatDetail extends StatefulWidget {
  final ConversationModel chatInfo;

  const ChatDetail(this.chatInfo, {super.key});

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  late ChatManager chatManager;
  late FocusNode _focusNode;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();

  final String channelName = Pusher_Linker.getChannelName();

  bool chatSelectionMode = false;
  bool emojiVisible = false;

  int page = 0;
  bool hasMore = true;
  bool isLoading = false;

  List<Message> selectedMessages = [];
  late int currentUserId;

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.extentAfter < 200 && !isLoading && hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (isLoading || !hasMore) return;
    setState(() => isLoading = true);
    final before = chatManager.userConversationMessages.length;
    await chatManager.getConversationsMessages(page, widget.chatInfo.id);
    final after = chatManager.userConversationMessages.length;
    if (after == before) {
      hasMore = false;
    } else {
      page++;
    }
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    chatManager = ChatManager.get(context);
    _focusNode = FocusNode();
    _scrollController.addListener(_onScroll);
    currentUserId = int.tryParse(SharedPrefHelper.getString('id') ?? '0') ?? 0;
    if (widget.chatInfo.id != '-1') {
      chatManager.getConversationsMessages(page, widget.chatInfo.id);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    chatManager.userConversationMessages.clear();
    chatManager.openConversationId = '-';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatManager, BLoCStates>(
      listener: (_, _) {},
      builder: (context, state) {
        final chat = chatManager.userConversationMessages;
        return Scaffold(
          appBar: _buildAppBar(),
          body: SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/chat_BG.jpg'),
                  fit: BoxFit.cover,
                  repeat: ImageRepeat.repeat,
                ),
              ),
              child: Column(
                children: [
                  Expanded(child: _buildMessagesList(chat, state)),
                  _buildMessageInput(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    if (chatSelectionMode) {
      return AppBar(
        backgroundColor: Colors.black,
        title: Text(
          '${selectedMessages.length} selected',
          style: const TextStyle(
            color: Colors.teal,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            setState(() {
              selectedMessages.clear();
              chatSelectionMode = false;
            });
          },
        ),
        actions: _buildAppBarActions(),
      );
    }

    return AppBar(
      backgroundColor: Colors.black,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.teal.withAlpha(38),
            child: ClipOval(
              child: widget.chatInfo.otherUserProfileImage != null
                  ? Image.network(
                      Constant.mediaURL +
                          widget.chatInfo.otherUserProfileImage!,
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
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.chatInfo.otherUserName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.teal,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert_outlined),
        ),
      ],
    );
  }

  Widget _buildMessagesList(List<Message> chat, BLoCStates state) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ListView.builder(
          reverse: true,
          controller: _scrollController,
          itemCount: chat.length,
          itemBuilder: (context, index) {
            final message = chat[index];
            final isMe = message.sender.id == currentUserId;

            String? dateHeader;
            if (index == chat.length - 1) {
              dateHeader = formatDate(message.date);
            } else if (!isSameDay(message.date, chat[index + 1].date)) {
              dateHeader = formatDate(message.date);
            }

            return Column(
              key: ValueKey(message.id),
              children: [
                if (dateHeader != null) _buildDateHeader(dateHeader),
                _buildMessageItem(message, isMe),
              ],
            );
          },
        ),
        if (state is LoadingState)
          const Positioned(
            top: 10,
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
          ),
      ],
    );
  }

  Widget _buildDateHeader(String text) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildMessageItem(Message message, bool isMe) {
    final isSelected = selectedMessages.contains(message);

    return GestureDetector(
      onLongPress: () {
        if (!chatSelectionMode) {
          setState(() {
            selectedMessages.add(message);
            chatSelectionMode = true;
          });
        }
      },
      onTap: () {
        if (!chatSelectionMode) return;
        setState(() {
          if (isSelected) {
            selectedMessages.remove(message);
            if (selectedMessages.isEmpty) {
              chatSelectionMode = false;
            }
          } else {
            selectedMessages.add(message);
          }
        });
      },
      child: Stack(
        children: [
          MessageBubble(
            content: message.content,
            type: message.type,
            isMe: isMe,
            time: message.date,
            status: isMe ? message.status : null,
            selectionMode: chatSelectionMode,
          ),
          if (isSelected)
            Positioned.fill(child: Container(color: Colors.teal.withAlpha(76))),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.only(
            left: 10,
            right: 10,
            bottom: 5,
            top: 10,
          ),
          child: Row(
            children: [
              Expanded(
                child: Material(
                  elevation: 10,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 55,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            emojiVisible
                                ? Icons.keyboard
                                : Icons.emoji_emotions_outlined,
                            color: Colors.teal.shade700,
                          ),
                          onPressed: _toggleEmoji,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'Message...',
                              border: InputBorder.none,
                            ),
                            onTap: () {
                              if (emojiVisible) {
                                setState(() => emojiVisible = false);
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.camera_alt,
                            color: Colors.teal.shade700,
                          ),
                          onPressed: _sendImage,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              _buildSendButton(),
            ],
          ),
        ),
        Offstage(
          offstage: !emojiVisible,
          child: SizedBox(
            height: 250,
            child: EmojiPicker(
              textEditingController: _controller,
              onBackspacePressed: _onEmojiBackspace,
              config: Config(
                height: 256,
                checkPlatformCompatibility: true,
                emojiViewConfig: EmojiViewConfig(
                  noRecents: const Text(
                    'No Recents',
                    style: TextStyle(fontSize: 16, color: Colors.white),
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
                searchViewConfig: const SearchViewConfig(
                  backgroundColor: Colors.black,
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
    );
  }

  void _onEmojiBackspace() {
    _controller
      ..text = _controller.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
  }

  Widget _buildSendButton() {
    return InkWell(
      onTap: _sendText,
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
    );
  }

  List<Widget> _buildAppBarActions() {
    bool hasImage = selectedMessages.any((m) => m.type == 'IMAGE');
    bool hasText = selectedMessages.any((m) => m.type == 'TEXT');

    if (selectedMessages.length > 1) {
      bool sentByMe = selectedMessages.every(
        (m) => m.sender.id == currentUserId,
      );

      if (!sentByMe) return [];

      return [
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            ReusableComponents.deleteDialog<ChatManager>(context, () async {
              await chatManager.deleteMessage({
                "channel_name": channelName,
                "messageIds": selectedMessages.map((m) => m.id).toList(),
              });
              setState(() {
                selectedMessages.clear();
                chatSelectionMode = false;
              });
            }, body: 'are you sure to delete this messages from everyone?');
          },
        ),
      ];
    }

    if (selectedMessages.length == 1) {
      final message = selectedMessages.first;
      final sentByMe = message.sender.id == currentUserId;

      if (hasText) {
        return [
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: message.content));
              setState(() {
                selectedMessages.clear();
                chatSelectionMode = false;
              });
            },
          ),
          if (sentByMe)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                ReusableComponents.deleteDialog<ChatManager>(
                  context,
                  () async {
                    await chatManager.deleteMessage({
                      "channel_name": channelName,
                      "messageIds": [message.id],
                    });
                    setState(() {
                      selectedMessages.clear();
                      chatSelectionMode = false;
                    });
                  },
                  body: 'are you sure to delete this message from everyone?',
                );
              },
            ),
        ];
      }
      if (hasImage) {
        return [
          IconButton(
            icon: const Icon(Icons.save_alt, color: Colors.white),
            onPressed: () async {
              await ReusableComponents.saveImageToGallery(
                Constant.mediaURL + message.content,
              );
            },
          ),
          if (sentByMe)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                ReusableComponents.deleteDialog<ChatManager>(
                  context,
                  () async {
                    await chatManager.deleteMessage({
                      "channel_name": channelName,
                      "messageIds": [message.id],
                    });
                    setState(() {
                      selectedMessages.clear();
                      chatSelectionMode = false;
                    });
                  },
                  body: 'are you sure to delete this message from everyone?',
                );
              },
            ),
        ];
      }
    }
    return [];
  }

  Future<void> _toggleEmoji() async {
    if (emojiVisible) {
      _focusNode.requestFocus();
    } else {
      FocusScope.of(context).unfocus();
      await SystemChannels.textInput.invokeMethod('TextInput.hide');
    }

    setState(() {
      emojiVisible = !emojiVisible;
    });
  }

  void _sendText() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    chatManager.sendTextMessage({
      "channel_name": channelName,
      "receiverId": widget.chatInfo.otherUserId,
      "content": text,
    });

    _controller.clear();
  }

  Future<void> _sendImage() async {
    final XFile? image = await ReusableComponents.pickImage();
    if (image == null) return;

    chatManager.sendFileMessage({
      "channel_name": channelName,
      "receiverId": widget.chatInfo.otherUserId,
      "messageType": 'IMAGE',
    }, image);
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
