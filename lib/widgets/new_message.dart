import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:medcorder_audio/medcorder_audio.dart';

// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/foundation.dart';

class NewMessage extends StatefulWidget {
  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var _message = '';
  final _controller = new TextEditingController();
  PickedFile _imageFile;
  // dynamic _pickImageError;
  bool isVideo = false;
  VideoPlayerController _vcontroller;
  // VideoPlayerController _toBeDisposed;
  MedcorderAudio audioModule = new MedcorderAudio();
  bool canRecord = false;
  double recordPower = 0.0;
  double recordPosition = 0.0;
  bool isRecord = false;
  String file = "";
  final ImagePicker _picker = ImagePicker();
  void _mediaMessage(
    ImageSource source,
  ) async {
    if (_vcontroller != null) {
      await _vcontroller.setVolume(0.0);
    }
    if (isVideo) {
      final PickedFile file = await _picker.getVideo(
          source: source, maxDuration: const Duration(seconds: 10));
      // await _playVideo(file);
    } else {
      final pickedFile = await _picker.getImage(
        source: source,
      );
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  @override
  initState() {
    super.initState();
    audioModule.setCallBack((dynamic data) {
      _onEvent(data);
    });
    _initSettings();
  }

  Future _initSettings() async {
    final String result = await audioModule.checkMicrophonePermissions();
    if (result == 'OK') {
      await audioModule.setAudioSettings();
      setState(() {
        canRecord = true;
      });
    }
    return;
  }

  Future _startRecord() async {
    try {
      DateTime time = new DateTime.now();
      setState(() {
        file = time.millisecondsSinceEpoch.toString();
      });
      final String result = await audioModule.startRecord(file);
      setState(() {
        isRecord = true;
      });
      print('startRecord: ' + result);
    } catch (e) {
      file = "";
      print('startRecord: fail');
    }
  }

  Future _stopRecord() async {
    try {
      final String result = await audioModule.stopRecord();
      print('stopRecord: ' + result);
      setState(() {
        isRecord = false;
      });
    } catch (e) {
      print('stopRecord: fail');
      setState(() {
        isRecord = false;
      });
    }
  }

  void _onEvent(dynamic event) {
    print(event);
    if (event['code'] == 'recording') {
      double power = event['peakPowerForChannel'];
      // String url = event['url'];
      // print(url);
      setState(() {
        recordPower = (60.0 - power.abs().floor()).abs();
        recordPosition = event['currentTime'];
      });
    }
  }

  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    FirebaseFirestore.instance.collection('chat').add({
      'Text': _message,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData['username'],
      'userImage': userData['image_url'],
    });
    _controller.clear();
    _message = '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(icon: Icon(Icons.emoji_emotions), onPressed: () {}),
          Expanded(
            child: isRecord
                ? new Text('recording: ' + recordPosition.toString())
                : TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: true,
                    enableSuggestions: true,
                    controller: _controller,
                    decoration: InputDecoration(
                        labelText: 'Send a message...',
                        border: InputBorder.none),
                    onChanged: (value) {
                      setState(() {
                        _message = value;
                      });
                    },
                  ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.camera_alt, color: Colors.amber),
                onPressed: () {
                  _cameraDialog(context);
                },
              ),
              InkWell(
                child: Icon(isRecord ? Icons.mic_off : Icons.mic,
                    color: Colors.amber),
                onTap: () {
                  isRecord ? _stopRecord() : _startRecord();
                },
              )
            ],
          ),
          IconButton(
            icon: Icon(Icons.send,
                color: _message.trim().isEmpty ? Colors.grey : Colors.amber),
            onPressed: _message.trim().isEmpty ? null : _sendMessage,
          ),
        ],
      ),
    );
  }

  _cameraDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    setState(() {
                      isVideo = false;
                    });
                    _mediaMessage(ImageSource.camera);
                  },
                  child: Text('Picture from camera'),
                ),
                FlatButton(
                  onPressed: () {
                    setState(() {
                      isVideo = false;
                    });
                    _mediaMessage(ImageSource.gallery);
                  },
                  child: Text('Picture from gallery'),
                ),
                FlatButton(
                  onPressed: () {
                    setState(() {
                      isVideo = true;
                    });
                    _mediaMessage(ImageSource.camera);
                  },
                  child: Text('Video from camera'),
                ),
                FlatButton(
                  onPressed: () {
                    setState(() {
                      isVideo = true;
                    });
                    _mediaMessage(ImageSource.gallery);
                  },
                  child: Text('Video from gallery'),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
