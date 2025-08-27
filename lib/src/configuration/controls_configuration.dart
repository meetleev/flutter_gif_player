import 'package:flutter/material.dart';

import '../progress_colors.dart';

const Color _defaultCupertinoBackgroundColor = Color.fromRGBO(41, 41, 41, 0.7);
const Color _defaultCupertinoIconColor = Color.fromARGB(255, 200, 200, 200);

class GifPlayerControlsConfiguration {
  /// The colors to use for the Material Progress Bar. By default, the Material
  /// player uses the colors from your Theme.
  final ProgressColors? materialProgressColors;

  /// The colors to use for controls on iOS. By default, the iOS player uses
  /// colors sampled from the original iOS 11 designs.
  final ProgressColors? cupertinoProgressColors;

  /// The progressbar offset from the bottom.
  final double paddingBottom;

  /// The colors to use for background on iOS.
  final Color cupertinoBackgroundColor;

  /// The colors to use for background on Material.
  final Color materialBackgroundColor;

  /// The colors to use for icon on Material.
  final Color materialIconColor;

  /// The colors to use for icon on Cupertino.
  final Color cupertinoIconColor;

  GifPlayerControlsConfiguration({
    this.materialProgressColors,
    this.cupertinoProgressColors,
    this.paddingBottom = 0,
    this.materialBackgroundColor = Colors.black12,
    this.materialIconColor = Colors.white,
    this.cupertinoBackgroundColor = _defaultCupertinoBackgroundColor,
    this.cupertinoIconColor = _defaultCupertinoIconColor,
  });
}
