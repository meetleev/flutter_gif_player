import 'dart:io';

import 'package:example/constants.dart';
import 'package:example/page/data_source_page.dart';
import 'package:example/page/gif_player_event_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'progress_bar_padding_bottom_page.dart';

class MaterialHomePage extends StatefulWidget {
  const MaterialHomePage({super.key, required this.title});

  final String title;

  @override
  State<MaterialHomePage> createState() => _MaterialHomePageState();
}

class _MaterialHomePageState extends State<MaterialHomePage> {
  @override
  void initState() {
    super.initState();
    _saveAssetVideoToFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('gif player test')),
      body: ListView(children: [..._buildExampleWidgets()]),
    );
  }

  List<Widget> _buildExampleWidgets() {
    return [
      _buildExampleElementWidget('Data source', () {
        _navigateToPage(const DataSourcePage());
      }),
      _buildExampleElementWidget('GifPlayer bottom bar padding bottom', () {
        _navigateToPage(const ProgressBarPaddingBottomPage());
      }),
      _buildExampleElementWidget('GifPlayer event', () {
        _navigateToPage(const GifPlayerEventPage());
      }),
    ];
  }

  Future _navigateToPage(Widget routeWidget) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => routeWidget),
    );
  }

  Widget _buildExampleElementWidget(String name, Function() onClicked) {
    return InkWell(
      onTap: onClicked,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.orange,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(name, style: const TextStyle(fontSize: 18)),
          ),
          const Divider(),
        ],
      ),
    );
  }

  /// Save gif to file, so we can use it later
  Future _saveAssetVideoToFile() async {
    if (kIsWeb) return;
    var content = await rootBundle.load(assetGifUrl);
    final directory = await getTemporaryDirectory();
    File file = File('${directory.path}/$fileGifName');
    await file.writeAsBytes(content.buffer.asUint8List());
  }
}
