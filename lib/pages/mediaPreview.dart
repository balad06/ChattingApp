import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/foundation.dart';

class MediaPreview extends StatefulWidget {
  static const id = 'preview';
  @override
  _MediaPreviewState createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  dynamic _pickImageError;
  VideoPlayerController _vidcontroller;
  VideoPlayerController _toBeDisposed;
  String _retrieveDataError;
  var _message = '';
  final _controller = new TextEditingController();

  @override
  void deactivate() {
    if (_vidcontroller != null) {
      _vidcontroller.setVolume(0.0);
      _vidcontroller.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _disposeVideoController();
    super.dispose();
  }

  Future<void> _disposeVideoController() async {
    if (_toBeDisposed != null) {
      await _toBeDisposed.dispose();
    }
    _toBeDisposed = _vidcontroller;
    _vidcontroller = null;
  }

  Text _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Widget _previewVideo(file) {
    final Text retrieveError = _getRetrieveErrorWidget();
    _vidcontroller = VideoPlayerController.file(File(file.path));
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_vidcontroller == null) {
      return const Text(
        'You have not yet picked a video',
        textAlign: TextAlign.center,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AspectRatioVideo(_vidcontroller),
    );
  }

  Widget _previewImage(File file) {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (file != null) {
      if (kIsWeb) {
        return Image.network(file.path);
      } else {
        print('preview');
        return Semantics(
            child: Image.file(
              File(file.path),
              width: double.infinity,
            ),
            label: 'image_picker_example_picked_image');
      }
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  void _sendMessage(File file) async {
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    print(userData);
    print(_message);
    final ref = FirebaseStorage.instance
        .ref()
        .child('chatMedia')
        .child(Timestamp.now().toString() + userData['username'] + '.jpg');
    await ref.putFile(file).whenComplete(() => null);
    final imageUrl = await ref.getDownloadURL();
    FirebaseFirestore.instance.collection('chat').add({
      'Text': _message,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData['username'],
      'userImage': userData['image_url'],
      'isImage': true,
      'imageUrl': imageUrl,
    });
    _controller.clear();
    _message = '';
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments as List;
    bool isVideo = args[1] as bool;
    File file = args[0] as File;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        leading: Row(
          children: [
            IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: isVideo ? _previewVideo(file) : _previewImage(file),
            ),
            Row(
              children: [
                IconButton(
                    icon: Icon(
                      Icons.emoji_emotions,
                      color: Colors.amber,
                    ),
                    onPressed: () {}),
                Expanded(
                  child: TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: true,
                    enableSuggestions: true,
                    controller: _controller,
                    decoration: InputDecoration(
                        fillColor: Colors.transparent,
                        labelText: 'Send a message...',
                        border: InputBorder.none),
                    onChanged: (value) {
                      setState(() {
                        _message = value;
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send,
                      color: (file == null) ? Colors.grey : Colors.amber),
                  onPressed: (file == null)
                      ? null
                      : () {
                          _sendMessage(file);
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AspectRatioVideo extends StatefulWidget {
  AspectRatioVideo(this.controller);

  final VideoPlayerController controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController get controller => widget.controller;
  bool initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller.value.initialized) {
      initialized = controller.value.initialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller.removeListener(_onVideoControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller.value?.aspectRatio,
          child: VideoPlayer(controller),
        ),
      );
    } else {
      return Container();
    }
  }
}
