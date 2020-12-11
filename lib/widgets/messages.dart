// import 'package:ChattingApp/widgets/image_bubble.dart';
import 'package:ChattingApp/widgets/image_bubble.dart';
import 'package:ChattingApp/widgets/message_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Messages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return FutureBuilder(
      // future: FirebaseAuth.instance.currentUser,
      builder: (ctx, snapShots) {
        if (snapShots.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('chat')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (ctx, chatSnapshot) {
              if (chatSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              final chatDocs = chatSnapshot.data.documents;
              return ListView.builder(
                reverse: true,
                itemBuilder: (ctx, i) => chatDocs[i]['isImage']
                    ? ImageBubble(
                      message: chatDocs[i]['Text'],
                        isMe: chatDocs[i]['userId'] == user.uid,
                        key: ValueKey(
                          chatDocs[i].documentID,
                        ),
                        username: chatDocs[i]['username'],
                        userImageurl: chatDocs[i]['userImage'],
                        chatImage: chatDocs[i]['imageUrl'],
                    )
                    : MessageBubble(
                        message: chatDocs[i]['Text'],
                        isMe: chatDocs[i]['userId'] == user.uid,
                        key: ValueKey(
                          chatDocs[i].documentID,
                        ),
                        username: chatDocs[i]['username'],
                        userImageurl: chatDocs[i]['userImage'],
                      ),
                itemCount: chatDocs.length,
              );
            });
      },
    );
  }
}
