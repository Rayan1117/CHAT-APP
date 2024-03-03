import "package:chat_app/message_bubble.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

final isAuthenticator = FirebaseAuth.instance.currentUser!;

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});


  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy("time", descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text("no message found"),
          );
        }

        if (chatSnapshots.hasError) {
          return const Center(
            child: Text("something went wrong"),
          );
        }

        final loadedMessage = chatSnapshots.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          reverse: true,
          itemCount: loadedMessage.length,
          itemBuilder: (ctx, index) {
            final chatMessage = loadedMessage[index].data();
            final nextMessage = index + 1 < loadedMessage.length
                ? loadedMessage[index + 1].data()
                : null;

            final currentUserId = chatMessage["userId"];
            final nextUserId =
                nextMessage != null ? nextMessage["userId"] : null;

            final isSameUser = currentUserId == nextUserId;

            if (isSameUser) {
              return MessageBubble.next(
                  message: chatMessage["message"],
                  isMe: isAuthenticator.uid == currentUserId);
            } else {
              return MessageBubble.first(
                  userImage: chatMessage["imageUrl"],
                  username: chatMessage["username"],
                  message: chatMessage["message"],
                  isMe: isAuthenticator.uid == currentUserId);
            }
          },
        );
      },
    );
  }
}
