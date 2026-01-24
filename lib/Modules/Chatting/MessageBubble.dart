import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import '../../BLoC/ChatManager.dart';
import '../../Models/ChattingModel.dart';
import '../../Shared/Constant.dart';

class MessageBubble extends StatelessWidget {
  final String content;
  final String type;
  final bool isMe;
  final DateTime time;
  final MessageStatus? status;

  const MessageBubble({
    super.key,
    required this.content,
    required this.type,
    required this.isMe,
    required this.time,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final Color coachColor = const Color(0xFFE0E0E0);
    final Color userStartColor = Colors.teal.shade500;
    final Color userEndColor = Colors.teal.shade800;
    final Color textColor = isMe ? Colors.white : Colors.black87;
    final ChatManager manager = ChatManager.get(context);
    final bool isImage = type == "IMAGE";

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Container(
          constraints: BoxConstraints(
            minWidth: Constant.screenWidth * 0.25,
            maxWidth: Constant.screenWidth * 0.70,
          ),
          padding: isImage
              ? const EdgeInsets.all(6)
              : const EdgeInsets.fromLTRB(14, 10, 10, 20),
          decoration: BoxDecoration(
            gradient: isMe && !isImage
                ? LinearGradient(
                    colors: [userStartColor, userEndColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isMe
                ? (isImage ? Colors.transparent : null)
                : (isImage ? Colors.transparent : coachColor),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: isMe
                  ? const Radius.circular(18)
                  : const Radius.circular(4),
              bottomRight: isMe
                  ? const Radius.circular(4)
                  : const Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: isMe ? Colors.teal.withAlpha(153) : coachColor.withAlpha(230),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: isImage ? 28.0 : 16.0),
                child: _buildMessageItem(context,textColor,manager)
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('hh:mm a').format(time),
                      style: TextStyle(
                        color: isMe ? Colors.white70 : Colors.black54,
                        fontSize: 11.0,
                      ),
                    ),
                    if (isMe && status != null) ...[
                      const SizedBox(width: 4),
                      _buildStatusIcon(status!),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return const Icon(Icons.access_time, size: 14, color: Colors.white70);
      case MessageStatus.sent:
        return const Icon(
          Icons.done_all,
          size: 14,
          color: Colors.white70,
        );
      case MessageStatus.failed:
        return const Icon(
          Icons.error_outline,
          size: 14,
          color: Colors.redAccent,
        );
    }
  }

  Widget _buildMessageItem(BuildContext context,Color textColor,ChatManager manager) {
    switch (type) {
      case "IMAGE":
        return _buildImageMessage(context,manager);
      case "TEXT":
      default:
        return _buildTextMessage(textColor);
    }
  }

  Widget _buildTextMessage(Color textColor) {
    return Text(
      content,
      style: TextStyle(
        color: textColor,
        fontSize: 15.0,
        height: 1.3,
      ),
    );
  }

  Widget _buildImageMessage(BuildContext context,ChatManager manager) {
    if (manager.chatSelectionMode){
      return buildClipRRect();
    } else {
      return GestureDetector(
        onTap: () {
          if (!manager.chatSelectionMode) {
            showDialog(
              context: context,
              builder: (_) => Dialog(
                backgroundColor: Colors.black,
                insetPadding: EdgeInsets.zero,
                child: Stack(
                  children: [
                    Center(
                      child: PhotoView(
                        imageProvider:
                        content.startsWith('/data/')
                            ? FileImage(File(content))
                            : NetworkImage(
                          Constant.mediaURL + content,
                        )
                        as ImageProvider,
                        backgroundDecoration: const BoxDecoration(
                          color: Colors.black,
                        ),
                        minScale:
                        PhotoViewComputedScale.contained,
                        maxScale:
                        PhotoViewComputedScale.covered * 2.5,
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 20,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
        child: buildClipRRect(),
      );
    }
  }

  Widget buildClipRRect () => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: content.startsWith('/data/') ? Image.file(
      File(content),
      width: 200,
      height: 200,
      fit: BoxFit.cover,
    ) : Image.network(
      // (length - 5) to remove '/api/' from baseURL
      Constant.baseAppURL.substring(0,
          Constant.baseAppURL.length - 5) + content,
      width: 200,
      height: 200,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 200,
          height: 200,
          color: Colors.grey.shade300,
          alignment: Alignment.center,
          child: const Icon(
            Icons.broken_image,
            size: 50,
            color: Colors.grey,
          ),
        );
      },
    ),
  );

}
