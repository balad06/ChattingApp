import 'package:ChattingApp/widgets/messages.dart';
import 'package:ChattingApp/widgets/new_message.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ChatScreen extends StatefulWidget {
  static const id = 'chatScreen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    final fbm = FirebaseMessaging();
    fbm.requestNotificationPermissions();
    fbm.configure(onMessage: (msg) {
      print(msg);
      return;
    }, onLaunch: (msg) {
      print(msg);
      return;
    }, onResume: (msg) {
      print(msg);
      return;
    });
    fbm.subscribeToTopic('chat');
  }

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
            'Global Chats',
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
