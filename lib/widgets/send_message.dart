import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SendMessage extends StatefulWidget {
  const SendMessage({super.key});
  @override
  State<SendMessage> createState() {
    return _SendMessage();
  }
}

class _SendMessage extends State<SendMessage> {
  var messageCtrl = TextEditingController();

  void _submitMessage() async {
    final enteredMessage = messageCtrl.text;
    if (enteredMessage.trim().isEmpty) {
      return;
    }

    //gestion de l'affichage du clavier a la fin
    FocusScope.of(context).unfocus(); // on retire l'apparition de clavier
    messageCtrl.clear(); // et on vide l'input du message

    // -------------------Récupération des données de l'utilisateur

    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'date': DateTime.now(),
      'userId': user.uid,
      'username': userData.data()!['username'],
      'userImage': userData.data()!['image_url'],
    });
  }

  @override
  void dispose() {
    messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageCtrl,
                    autocorrect: true,
                    textCapitalization: TextCapitalization.sentences,
                    enableSuggestions: true,
                    decoration: InputDecoration(labelText: 'Envoyer un message...'),
                  ),
                ),
                IconButton(
                  onPressed: _submitMessage,
                  icon: Icon(Icons.send),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
