import "package:chat_app/ChatMessage.dart";
import "package:chat_app/NewMessage.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat App"), actions: [
        IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.exit_to_app))
      ]),
      body: const Column(
        children: [Expanded(child: ChatMessage()), NewMessage()],
      ),
    );
  }
}
