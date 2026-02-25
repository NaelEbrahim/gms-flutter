import 'package:gms_flutter/Models/ProfileModel.dart';

class ConversationModel {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserProfileImage;
  String? lastMessage;
  String? lastMessageType;
  String? lastMessageTime;
  String? unreadCount;

  ConversationModel({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserProfileImage,
    this.lastMessage,
    this.lastMessageType,
    this.lastMessageTime,
    this.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> data) {
    return ConversationModel(
      id: data['conversationId'].toString(),
      otherUserId: data['otherUserId'].toString(),
      otherUserName: data['otherUsername'],
      otherUserProfileImage: data['otherUserProfileImage'] as String?,
      lastMessage: data['lastMessage'] as String?,
      lastMessageType: data['lastMessageType'] as String?,
      lastMessageTime: data['lastMessageTime'] as String?,
      unreadCount: data['unreadCount'].toString() as String?,
    );
  }

  static List<ConversationModel> parseList(List<dynamic> jsonList) {
    return jsonList.map((e) => ConversationModel.fromJson(e)).toList();
  }
}

class ChatModel {
  final UserModel otherParticipant;
  final List<Message> messages;

  ChatModel({required this.otherParticipant, required this.messages});

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      otherParticipant: UserModel.fromJson(json['otherParticipant']),
      messages: (json['messages'] as List)
          .map((msg) => Message.fromJson(msg))
          .toList(),
    );
  }

  static List<ChatModel> parseList(List<dynamic> jsonList) {
    return jsonList.map((e) => ChatModel.fromJson(e)).toList();
  }
}

class Message {
  final int? id;
  final dynamic content;
  final String type;
  final DateTime date;
  final String conversationId;
  final UserModel sender;
  final UserModel receiver;
  MessageStatus status;
  final String? tempId;

  Message({
    this.id,
    required this.content,
    required this.type,
    required this.date,
    required this.conversationId,
    required this.sender,
    required this.receiver,
    this.status = MessageStatus.sending,
    this.tempId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      type: json['type'],
      date: DateTime.parse(json['date']),
      conversationId: json['conversationId'].toString(),
      sender: UserModel.fromJson(json['sender']),
      receiver: UserModel.fromJson(json['receiver']),
      status: MessageStatus.sent,
    );
  }

  static List<Message> parseList(List<dynamic> jsonList) {
    return jsonList.map((e) => Message.fromJson(e)).toList();
  }
}

class LiveMessageModel {
  String conversationId;
  String senderId;
  String senderFirstName;
  String senderLastName;
  String senderProfileImage;
  String receiverId;
  String messageId;
  String messageType;
  String message;
  String timeStamp;

  LiveMessageModel({
    required this.conversationId,
    required this.senderId,
    required this.senderFirstName,
    required this.senderLastName,
    required this.senderProfileImage,
    required this.receiverId,
    required this.messageId,
    required this.messageType,
    required this.message,
    required this.timeStamp,
  });

  factory LiveMessageModel.fromJson(Map<String, dynamic> json) {
    return LiveMessageModel(
      conversationId: json['conversationId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderFirstName: json['senderFirstName']?.toString() ?? '',
      senderLastName: json['senderLastName']?.toString() ?? '',
      senderProfileImage: json['senderProfileImage']?.toString() ?? '',
      receiverId: json['receiverId']?.toString() ?? '',
      messageId: json['messageId']?.toString() ?? '',
      messageType: json['messageType']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      timeStamp: json['timeStamp']?.toString() ?? '',
    );
  }

  static Message convertLiveMessageToMessage(LiveMessageModel liveMessage) {
    return Message(
      id: int.parse(liveMessage.messageId),
      content: liveMessage.message,
      type: liveMessage.messageType,
      date: DateTime.parse(liveMessage.timeStamp),
      sender: UserModel(
        id: int.parse(liveMessage.senderId),
        firstName: liveMessage.senderFirstName,
        lastName: liveMessage.senderLastName,
        dob: '',
        email: '',
        gender: '',
        phoneNumber: '',
        profileImagePath: '',
        createdAt: '',
      ),
      receiver: UserModel.withId(int.parse(liveMessage.receiverId)),
      status: MessageStatus.sent,
      conversationId: liveMessage.conversationId,
    );
  }
}

enum MessageStatus { sending, sent, failed }
