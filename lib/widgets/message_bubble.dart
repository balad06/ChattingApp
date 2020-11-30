import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final isMe;
  final Key key;
  final String userName;
  MessageBubble({this.message, this.isMe, this.key, this.userName});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isMe ? Colors.orangeAccent : Colors.purple,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  userName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
