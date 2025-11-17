import 'package:chatapp/widgets/message_bubbule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatListMessage extends StatelessWidget {
  const ChatListMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticateUser = FirebaseAuth.instance.currentUser!;
    // return Center(child: Text("Aucun mlessage pour le moment...."));
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (ctx, chatData) {
        final loadData = chatData.data!.docs;
        if (chatData.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!chatData.hasData || chatData.data!.docs.isEmpty) {
          return const Center(child: Text("Aucun mlessage pour le moment...."));
        }

        if (chatData.hasError) {
          return const Center(child: Text("Erreur lors du chargement des données"));
        }

        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
          itemCount: loadData.length,
          itemBuilder: (ctx, index) {
            final chatMessage = loadData[index].data();
            final nextChatMessage = index + 1 < loadData.length ? loadData[index + 1].data() : null;
            final currentMesageUserId = chatMessage['userId'];
            final nextMessageUserId = nextChatMessage != null ? nextChatMessage['UserId'] : null;
            final nextUserIsSame = nextMessageUserId == currentMesageUserId;
            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatMessage['text'],
                isMe: authenticateUser.uid == currentMesageUserId,
              );
            } else {
              return MessageBubble.first(
                userImage: chatMessage['userImage'],
                username: chatMessage['username'],
                message: chatMessage['text'],
                isMe: authenticateUser.uid == currentMesageUserId,
              );
            }
          },
        );
      },
    );
  }
}
