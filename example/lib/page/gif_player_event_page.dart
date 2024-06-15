import 'dart:ffi';

import 'package:example/constants.dart';
import 'package:flutter/material.dart';
import 'package:gif_player/gif_player.dart';

class GifPlayerEventPage extends StatefulWidget {
  const GifPlayerEventPage({super.key});

  @override
  State<GifPlayerEventPage> createState() => _GifPlayerEventPageState();
}

class _GifPlayerEventPageState extends State<GifPlayerEventPage> {
  GifPlayerController? _controller;

  GifPlayerController get controller => _controller!;
  String _event = '';

  @override
  void initState() {
    super.initState();
    _loadGif();
    controller.addPlayerEventListener(_onPlayerEvent);
  }

  _onPlayerEvent(GifPlayerEvent event) {
    final params = event.data;
    switch (event.eventType) {
      case GifPlayerEventType.initialized:
        _event = 'initialized';
        break;
      case GifPlayerEventType.play:
        _event = 'play';
        break;
      case GifPlayerEventType.pause:
        _event = 'pause';
        break;
      case GifPlayerEventType.seekTo:
        _event = 'seekTo $params';
        break;
      case GifPlayerEventType.controlsVisibleChange:
        _event =
            'controlsVisibleChange ${params as bool ? 'visible' : 'invisible'}';
        break;
      case GifPlayerEventType.finished:
        _event = 'finished';
        break;
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _loadGif() {
    // _controller?.dispose();
    _controller = GifPlayerController(
        backgroundColor: Colors.black,
        dataSource: GifPlayerDataSource.asset(assetGifUrl),
        controlsConf: GifPlayerControlsConfiguration(paddingBottom: 20));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GifPlayer Event'),
      ),
      body: null != _controller
          ? Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: GifPlayer(controller: controller, fit: BoxFit.fill),
                ),
                Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 100),
                  child: Text(
                    _event,
                    style: const TextStyle(fontSize: 20),
                  ),
                )
              ],
            )
          : Container(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
