import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:image_picker/image_picker.dart';

import '../Models/ChattingModel.dart';
import '../Models/ProfileModel.dart';
import '../Remote/Dio_Linker.dart';
import '../Remote/End_Points.dart';
import '../Remote/Pusher_Linker.dart';
import '../Shared/SharedPrefHelper.dart';

class ChatManager extends Cubit<BLoCStates> {
  ChatManager() : super(InitialState());

  static ChatManager get(BuildContext context) => BlocProvider.of(context);

  void updateState() {
    emit(UpdateNewState());
  }

  void sendTextMessage(Map<String, dynamic> data) {
    final receiverId = int.parse(data['receiverId']);
    // create temp Message
    Message tempMessage = Message(
      conversationId: '',
      type: 'TEXT',
      tempId: UniqueKey().toString(),
      sender: ProfileDataModel(
        id: int.tryParse(SharedPrefHelper.getString('id').toString()),
      ),
      receiver: ProfileDataModel(id: receiverId),
      content: data['content'],
      date: DateTime.now(),
      status: MessageStatus.sending,
    );
    // add temp message Locally
    _updateConversationMessages(message: tempMessage);
    Dio_Linker.postData(
          url: SENDTEXTMESSAGE,
          data: data,
        )
        .then((value) {
          final sentMessage = Message.fromJson(value.data['message']);
          // remove temp Message Locally
          userConversationMessages.removeWhere(
            (m) => m.tempId == tempMessage.tempId,
          );
          // add real Message Locally
          _updateConversationMessages(message: sentMessage);
          emit(SuccessState());
          // update last conversation message (or Create new one if not exist)
          _updateConversationList(sentMessage, true);
        })
        .catchError((error) {
          tempMessage.status = MessageStatus.failed;
          _updateConversationMessages(message: tempMessage);
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  Future<void> sendFileMessage(Map<String, dynamic> data, XFile image) async {
    final receiverId = int.parse(data['receiverId']);
    // create temp Message
    Message tempMessage = Message(
      conversationId: '',
      type: 'IMAGE',
      tempId: UniqueKey().toString(),
      sender: ProfileDataModel(
        id: int.tryParse(SharedPrefHelper.getString('id').toString()),
      ),
      receiver: ProfileDataModel(id: receiverId),
      content: image.path,
      date: DateTime.now(),
      status: MessageStatus.sending,
    );
    // add temp message Locally
    _updateConversationMessages(message: tempMessage);
    FormData formData = FormData.fromMap({
      'content': await MultipartFile.fromFile(image.path, filename: image.name),
      'receiverId': data['receiverId'],
      'messageType': data['messageType'],
    });
    Dio_Linker.postData(
          url: SENDFILEMESSAGE,
          data: formData,
        )
        .then((value) {
          final sentMessage = Message.fromJson(value.data['message']);
          // remove temp Message Locally
          userConversationMessages.removeWhere(
            (m) => m.tempId == tempMessage.tempId,
          );
          // add real Message Locally
          _updateConversationMessages(message: sentMessage);
          emit(SuccessState());
          // update last conversation message (or Create new one if not exist)
          _updateConversationList(sentMessage, true);
        })
        .catchError((error) {
          tempMessage.status = MessageStatus.failed;
          _updateConversationMessages(message: tempMessage);
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  List<Message> userConversationMessages = [];
  String openConversationId = '-';
  bool hasMoreMessages = true;
  bool isLoadingMessages = false;
  int currentChatPage = 0;

  void getConversationsMessages(String conversationId) {
    if (isLoadingMessages || !hasMoreMessages) return;
    isLoadingMessages = true;
    emit(LoadingState());
    Dio_Linker.getData(
          url: GETMESSAGES,
          params: {
            'conversationId': conversationId,
            'page': currentChatPage,
            'size': 50,
          },
        )
        .then((value) {
          final List<Message> newMessages = Message.parseList(
            value.data['message'],
          );
          if (newMessages.isEmpty) {
            hasMoreMessages = false;
          } else {
            userConversationMessages.addAll(
              newMessages.where(
                (msg) => !userConversationMessages.any(
                  (existing) => existing.id == msg.id,
                ),
              ),
            );
            userConversationMessages.sort((a, b) => b.date.compareTo(a.date));
            currentChatPage++;
          }
          // marks all messages as read
          var currentConversationIndex = userConversations.indexWhere(
            (chat) => chat.id == conversationId,
          );
          // mark as Opened Conversation
          openConversationId = userConversations[currentConversationIndex].id;
          userConversations[currentConversationIndex].unreadCount = '0';
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
    isLoadingMessages = false;
  }

  List<ConversationModel> userConversations = [];

  void getUserConversations() {
    emit(LoadingState());
    Dio_Linker.getData(
          url: GETUSERCHATS,
        )
        .then((value) {
          userConversations = ConversationModel.parseList(
            value.data['message'],
          );
          userConversations.sort(
            (a, b) => DateTime.parse(
              b.lastMessageTime.toString(),
            ).compareTo(DateTime.parse(a.lastMessageTime.toString())),
          );
          initChatsAndPusher();
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  Future<void> initChatsAndPusher() async {
    await Pusher_Linker.unsubscribeUserChannel();
    await Pusher_Linker.subscribeToUserChannel((message) {
      _handleIncomingMessage(message);
    });
  }

  void clearChatMessages() {
    userConversationMessages.clear();
    selectedMessages.clear();
    hasMoreMessages = true;
    isLoadingMessages = false;
    emojiVisible = false;
    chatSelectionMode = false;
    openConversationId = '-';
    currentChatPage = 0;
  }

  void clearConversations() async {
    await Pusher_Linker.unsubscribeUserChannel();
    userConversations.clear();
  }

  void _handleIncomingMessage(String data) {
    final message = LiveMessageModel.fromJson(jsonDecode(data));
    final newMessage = LiveMessageModel.convertLiveMessageToMessage(message);
    // Ignore messages that sent by me
    if (message.senderId == SharedPrefHelper.getString('id')) {
      return;
    }
    // Update messages inside the correct Opened conversation
    if (message.conversationId == openConversationId) {
      _updateConversationMessages(message: newMessage);
    }
    // Update conversations list (refresh last message)
    _updateConversationList(newMessage, false);
  }

  void _updateConversationMessages({required Message message}) {
    final existingIndex = userConversationMessages.indexWhere(
      (m) => m.id == message.id,
    );
    if (existingIndex != -1) {
      // Update existing message (if already in list)
      userConversationMessages[existingIndex] = message;
    } else {
      // Add new incoming message
      userConversationMessages.add(message);
    }
    // Sort messages by date (newest first)
    userConversationMessages.sort((a, b) => b.date.compareTo(a.date));
    emit(UpdateNewState());
  }

  void _updateConversationList(Message message, callBySender) {
    ConversationModel updatedChat;
    final index = userConversations.indexWhere(
      (chat) => chat.id == message.conversationId,
    );
    if (index != -1) {
      updatedChat = userConversations[index];
      updatedChat.lastMessage = message.content;
      updatedChat.lastMessageType = message.type;
      updatedChat.lastMessageTime = message.date.toString();
      // Increase unread count if conversation not opened
      if (openConversationId != message.conversationId) {
        updatedChat.unreadCount =
            (int.parse(updatedChat.unreadCount.toString()) + 1).toString();
      }
      userConversations
        ..removeAt(index)
        ..insert(0, updatedChat);
    } else {
      updatedChat = ConversationModel(
        id: message.conversationId,
        otherUserId: message.sender.id.toString(),
        otherUserName: (callBySender) ? '${message.receiver.firstName.toString()} ${message.receiver.lastName.toString()}'
        : '${message.sender.firstName.toString()} ${message.sender.lastName.toString()}',
        otherUserProfileImage: message.receiver.profileImagePath,
        lastMessage: message.content.toString(),
        lastMessageTime: message.date.toString(),
        lastMessageType: message.type,
        unreadCount: callBySender ? '0' : '1',
      );
      openConversationId = message.conversationId;
      userConversations.insert(0, updatedChat);
    }
    emit(UpdateNewState());
  }

  bool emojiVisible = false;

  void changeChatEmojiVisible() {
    emojiVisible = !emojiVisible;
    emit(UpdateNewState());
  }

  bool chatSelectionMode = false;
  List<Message> selectedMessages = [];

  void changeChatSelectionMode() {
    chatSelectionMode = !chatSelectionMode;
    emit(UpdateNewState());
  }

  void deleteMessage(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.deleteData(
          url: DELETEMESSAGE,
          data: data,
        )
        .then((value) {
          for (int messageId in data['messageIds']) {
            // close selection mode
            selectedMessages.clear();
            chatSelectionMode = false;
            // remove deleted messages from local list
            deleteMessageFromConversation(
              userConversationMessages.firstWhere(
                (message) => message.id == messageId,
              ),
            );
          }
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void deleteMessageFromConversation(Message message) {
    final conversation = userConversations.firstWhere(
      (c) => c.otherUserId == message.receiver.id.toString(),
      orElse: () => throw Exception('Conversation not found'),
    );
    // Remove the message
    userConversationMessages.removeWhere((m) => m.id == message.id);
    // Update lastMessage string
    if (userConversationMessages.isEmpty) {
      conversation.lastMessage = null;
    } else if (conversation.lastMessage == message.content) {
      conversation.lastMessage = userConversationMessages.first.content;
      conversation.lastMessageTime = userConversationMessages.first.date
          .toString();
      conversation.lastMessageType = userConversationMessages.first.type;
    }
  }

  void deleteConversation(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.deleteData(
          url: DELETECONVERSATION,
          data: data,
        )
        .then((value) {
          userConversations.removeWhere(
            (chat) => chat.id == data['conversationId'],
          );
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void updateConversationLastSeen(String conversationId) {
    Dio_Linker.putData(
      url: UPDATECONVERSATIONLASTSEEN,
      params: {'conversationId': conversationId},
    );
  }

  List<ProfileDataModel> coaches = [];
  bool hasMoreCoaches = true;
  bool isLoadingCoaches = false;

  void getCoaches() {
    if (isLoadingCoaches || !hasMoreCoaches) return;
    isLoadingCoaches = true;
    emit(LoadingState());
    Dio_Linker.getData(
          url: GETCOACHES,
          params: {'role': 'Coach'},
        )
        .then((value) {
          coaches = ProfileDataModel.parseList(value.data['message']);
          isLoadingCoaches = false;
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  String handleDioError(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Request Timeout, try again';
      }
      if (error.response?.data?['message'] != null) {
        return error.response!.data['message'].toString();
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'No internet connection or server unreachable.';
      }
    }
    return 'Unexpected error, try again later';
  }
}
