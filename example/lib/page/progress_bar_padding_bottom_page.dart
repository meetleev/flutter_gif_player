import 'package:example/constants.dart';
import 'package:flutter/material.dart';
import 'package:gif_player/gif_player.dart';
import 'package:group_button/group_button.dart';

class ProgressBarPaddingBottomPage extends StatefulWidget {
  const ProgressBarPaddingBottomPage({super.key});

  @override
  State<ProgressBarPaddingBottomPage> createState() =>
      _ProgressBarPaddingBottomPageState();
}

class _ProgressBarPaddingBottomPageState
    extends State<ProgressBarPaddingBottomPage> {
  GifPlayerController? _controller;

  GifPlayerController get controller => _controller!;
  final GroupButtonController _groupButtonController =
      GroupButtonController(selectedIndex: 0);

  @override
  void initState() {
    super.initState();
    _loadGif(20);
  }

  void _loadGif(double paddingBottom) {
    _controller?.dispose();
    _controller = GifPlayerController(
        dataSource: GifPlayerDataSource.asset(assetGifUrl),
        controlsConf:
            GifPlayerControlsConfiguration(paddingBottom: paddingBottom));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('progress bar padding bottom'),
      ),
      body: null != _controller
          ? Stack(
              children: [
                GifPlayer(controller: controller),
                Container(
                  padding: const EdgeInsets.only(top: 100),
                  alignment: Alignment.topCenter,
                  child: GroupButton(
                    controller: _groupButtonController,
                    buttons: const [20, 40, 60, 80, 100],
                    onSelected: (int title, idx, selected) {
                      _groupButtonController.selectIndex(idx);
                      _loadGif(title.toDouble());
                    },
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
