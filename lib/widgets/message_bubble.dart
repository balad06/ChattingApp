import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final isMe;
  final Key key;
  final String username;
  MessageBubble({this.message, this.isMe, this.key, this.username});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          width: 120,
          decoration: BoxDecoration(
            color: isMe ? Colors.grey[300] : Colors.deepPurple,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isMe ? Colors.black : Colors.white,
                  ),
                  textAlign: isMe ? TextAlign.right : TextAlign.left,
                ),
              ),
              Text(
                message,
                style: TextStyle(
                  color: isMe ? Colors.black : Colors.white,
                ),
                textAlign: isMe ? TextAlign.right : TextAlign.left,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
