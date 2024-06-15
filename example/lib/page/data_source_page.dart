import 'package:example/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gif_player/gif_player.dart';
import 'package:group_button/group_button.dart';
import 'package:path_provider/path_provider.dart';

class DataSourcePage extends StatefulWidget {
  const DataSourcePage({super.key});

  @override
  State<DataSourcePage> createState() => _DataSourcePageState();
}

class _DataSourcePageState extends State<DataSourcePage> {
  GifPlayerController? _controller;

  GifPlayerController get controller => _controller!;
  final GroupButtonController _groupButtonController =
      GroupButtonController(selectedIndex: 0);

  @override
  void initState() {
    super.initState();
    _loadGif(GifPlayerDataSourceType.values[0]);
  }

  void _loadGif(GifPlayerDataSourceType type) {
    // _controller?.dispose();
    switch (type) {
      case GifPlayerDataSourceType.asset:
        _controller = GifPlayerController(
            dataSource: GifPlayerDataSource.asset(assetGifUrl));
        setState(() {});
        break;
      case GifPlayerDataSourceType.network:
        _controller = GifPlayerController(
            dataSource: GifPlayerDataSource.network(remoteGifUrl),
            controlsConf: GifPlayerControlsConfiguration(paddingBottom: 10));
        setState(() {});
        break;
      case GifPlayerDataSourceType.file:
        getTemporaryDirectory().then((directory) {
          final String url = '${directory.path}/$fileGifName';
          _controller =
              GifPlayerController(dataSource: GifPlayerDataSource.file(url));
          setState(() {});
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> buttonLabs = ['asset', 'network'];
    if (!kIsWeb) {
      buttonLabs.add('file');
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data source'),
      ),
      body: null != _controller
          ? Stack(
              children: [
                Positioned.fill(
                  child: GifPlayer(controller: controller),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 100),
                  alignment: Alignment.topCenter,
                  child: GroupButton(
                    controller: _groupButtonController,
                    buttons: buttonLabs,
                    onSelected: (title, idx, selected) {
                      _groupButtonController.selectIndex(idx);
                      _loadGif(GifPlayerDataSourceType.values[idx]);
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
