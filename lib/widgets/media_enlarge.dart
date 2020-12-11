import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';

class Media extends StatefulWidget {
  static const id = 'enlarge';
  @override
  _MediaState createState() => _MediaState();
}

class _MediaState extends State<Media> {
  dynamic _pickImageError;
  VideoPlayerController _vidcontroller;
  VideoPlayerController _toBeDisposed;
  String _retrieveDataError;

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
    _vidcontroller = VideoPlayerController.network(file);
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

  Widget _previewImage(String file) {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (file != null) {
      if (kIsWeb) {
        return Image.network(file);
      } else {
        return Semantics(
            child: Image.network(
              file,
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

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments as List;
    bool isVideo = args[1] as bool;
    String file = args[0] as String;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Row(
          children: [
            IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
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
