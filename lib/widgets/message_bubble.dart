import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final isMe;
  final Key key;
  final String username;
  MessageBubble({this.message, this.isMe, this.key, this.username});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            username,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              // color: isMe ? Colors.black : Colors.white,
            ),
            textAlign: isMe ? TextAlign.right : TextAlign.left,
          ),
        ),
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 180),
              child: Container(
                // width: 120,
                decoration: BoxDecoration(
                  color: isMe ? Colors.amber : Colors.deepPurple,
                  borderRadius: isMe
                      ? BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        )
                      : BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                ),
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: TextStyle(
                        color: isMe ? Colors.black : Colors.white,
                      ),
                      // textAlign: isMe ? TextAlign.right : TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
