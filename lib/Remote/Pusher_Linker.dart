import 'package:gms_flutter/Shared/SharedPrefHelper.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'Dio_Linker.dart';
import 'End_Points.dart';

class Pusher_Linker {
  static final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  static bool _isInitialized = false;
  static bool isSubscribe = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    await _pusher.init(
      apiKey: "d044493efec8a33cec65",
      cluster: "ap2",
      onEvent: (event) {
        print("📩 Event: ${event.eventName} - ${event.data}");
      },
      onAuthorizer: (channelName, socketId, options) async {
        print("Authorizing: $channelName | socket: $socketId");
        try {
          final response = await Dio_Linker.postData(
            url: CHATAUTH,
            data: {"channel_name": channelName, "socket_id": socketId},
          );
          return response.data;
        } catch (e) {
          print("AUTH ERROR: $e");
        }
      },
      onError: (message, code, e) {
        print("Pusher Error: $message (Code: $code, Exception: $e)");
      },
      onConnectionStateChange: (current, previous) {
        print("Connection changed: $previous → $current");
        // Auto reconnect
        if (current == "DISCONNECTED") {
          Future.delayed(Duration(seconds: 2), () {
            _pusher.connect();
          });
        }
      },
    );
    await _pusher.connect();
    _isInitialized = true;
    print("Pusher connected.");
  }

  static Future<void> subscribeToUserChannel(
    Function(String data) onIncomingMessage,
  ) async {
    if (isSubscribe) {
      print("Already subscribed");
      return;
    }
    final channelName = getChannelName();
    await _pusher.subscribe(
      channelName: channelName,
      onEvent: (event) {
        if (event.eventName == "new-message") {
          onIncomingMessage(event.data ?? '');
        }
      },
      onSubscriptionSucceeded: (_) {
        print("Subscribed to user channel: $channelName");
        isSubscribe = true;
      },
      onSubscriptionError: (msg, e) {
        isSubscribe = false;
        print("Subscription error on $channelName: $msg");
      },
    );
  }

  static Future<void> unsubscribeUserChannel() async {
    final userId = SharedPrefHelper.getString("id");
    if (userId == null) return;
    final channelName = getChannelName();
    if (isSubscribe) {
      await _pusher.unsubscribe(channelName: channelName);
      isSubscribe = false;
      print("Unsubscribed from $channelName");
    }
  }

  static void disconnect() {
    _pusher.disconnect();
    print("👋 Pusher disconnected.");
  }

  static String getChannelName() {
    return "private-user-${SharedPrefHelper.getString('id')}";
  }
}
