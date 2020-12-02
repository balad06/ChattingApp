import 'package:ChattingApp/widgets/messages.dart';
import 'package:ChattingApp/widgets/new_message.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatelessWidget {
  static const id = 'chatScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Chats',
            style: TextStyle(color: Colors.black),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton(
                underline: Container(),
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.black,
                ),
                items: [
                  DropdownMenuItem(
                    child: Row(
                      children: [
                        Icon(Icons.exit_to_app_outlined),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                    value: 'logout',
                  )
                ],
                onChanged: (item) {
                  if (item == 'logout') {
                    FirebaseAuth.instance.signOut();
                  }
                }),
          )
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Messages(),
            ),
            NewMessage(),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     FirebaseFirestore.instance
      //         .collection('chat')
      //         .add({'Text': 'This was added by button'});
      //   },
      //   child: Icon(Icons.add),
      // ),
    );
  }
}
