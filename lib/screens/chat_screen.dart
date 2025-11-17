import 'package:chatapp/widgets/chat_list_message.dart';
import 'package:chatapp/widgets/send_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void _userLogout() {
    FirebaseAuth.instance.signOut();
  }

  void setupPushNotifications() async {
    final fcm = FirebaseMessaging.instance;
    // final notificationSettings = await fcm.getToken();
    await fcm.requestPermission();
    final token = await fcm.getToken();
    // print("------------------------------------------------------token");
    // print(token.toString());
    // print("--------------------------------------------------------token");
    fcm.subscribeToTopic("chat");
  }

  @override
  void initState() {
    super.initState();
    setupPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        appBar: AppBar(
          title: Text("Messagerie"),
          actions: [
            IconButton(
              onPressed: _userLogout,
              icon: Icon(Icons.logout_outlined, color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),

        body: Column(
          children: [
            Expanded(child: ChatListMessage()),
            SendMessage(),
          ],
        ),
      ),
    );
  }
}
