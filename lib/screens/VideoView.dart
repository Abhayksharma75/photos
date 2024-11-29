import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  const VideoView({
    Key? key,
    required this.videoFile,
  }) : super(key: key);

  final Future<File?> videoFile;

  @override
  State createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  late final VideoPlayerController _videoPlayerController;
  late final ChewieController _chewieController;
  bool _initialized = false;

  Future<void> _initVideo() async {
    final video = await widget.videoFile;
    _videoPlayerController = VideoPlayerController.file(video!)
      ..setLooping(true)
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController,
            autoPlay: true,
            looping: true,
            aspectRatio: _videoPlayerController.value.aspectRatio,
            fullScreenByDefault: true,
          );
        });
      });
  }

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  _initialized
          ?  AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: Chewie(
                  controller: _chewieController,
                ),
              )
          : const Center(
              child: CircularProgressIndicator(),
            );
  }
}
