import 'package:chat_app/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class chat_message extends StatelessWidget {
  const chat_message({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticateduser = FirebaseAuth.instance.currentUser;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy(
              "createdAt",
              descending: true,
            )
            .snapshots(),
        builder: (ctx, chatSnapshots) {
          if (chatSnapshots.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
            return Center(
              child: Text("No messages found"),
            );
          }
          if (chatSnapshots.hasError) {
            return Center(
              child: Text("Something went wrong"),
            );
          }

          final loadedmessage = chatSnapshots.data!.docs;

          return ListView.builder(
              padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
              reverse: true,
              itemCount: loadedmessage.length,
              itemBuilder: (context, index) {
                final chatmessage = loadedmessage[index].data();
                final nextchatmessage = index + 1 < loadedmessage.length
                    ? loadedmessage[index + 1].data()
                    : null;

                final currentmessageuserid = chatmessage["userid"];
                final nextmessageuserid =
                    nextchatmessage != null ? nextchatmessage["userid"] : null;
                final nextuserissame =
                    nextmessageuserid == currentmessageuserid;

                if (nextuserissame) {
                  return MessageBubble.next(
                      message: chatmessage['text'],
                      isMe: authenticateduser!.uid == currentmessageuserid);
                } else {
                  return MessageBubble.first(
                      userImage: chatmessage['userimage'],
                      username: chatmessage['username'],
                      message: chatmessage['text'],
                      isMe: authenticateduser!.uid == currentmessageuserid);
                }
              });
        });
  }
}
