import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../progress_colors.dart';
import 'center_play_button.dart';
import 'controls_state.dart';

class CupertinoControls extends StatefulWidget {
  const CupertinoControls({super.key});

  @override
  State<CupertinoControls> createState() => CupertinoControlsState();
}

class CupertinoControlsState extends ControlsState<CupertinoControls> {
  final marginSize = 5.0;

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    final orientation = mediaData.orientation;
    final barHeight = orientation == Orientation.portrait ? 26.0 : 47.0;
    final controls = Stack(
      alignment: AlignmentDirectional.center,
      children: [
        if (wasLoading) _buildLoading(),
        Positioned(
          left: 0,
          right: 0,
          bottom: controlsConf.paddingBottom + barHeight,
          top: 0,
          child: buildHitArea(),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: controlsConf.paddingBottom,
          child: SizedBox(
            height: barHeight,
            child: _buildBottomBar(barHeight),
          ),
        ),
      ],
    );
    return buildMain(
        child: AbsorbPointer(
            absorbing: !controlsVisible,
            child: controller.isFullScreen
                ? SafeArea(child: controls)
                : controls));
  }

  Widget _buildLoading() {
    return const Center(
      child: CupertinoActivityIndicator(),
    );
  }

  Widget _buildBottomBar(double barHeight) {
    final iconColor = controlsConf.cupertinoIconColor;
    return /*SafeArea(
        bottom: controller.isFullScreen,
        child:*/
        AnimatedOpacity(
      opacity: !controlsVisible ? 0 : 1,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: marginSize),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                  height: barHeight,
                  color: controlsConf.cupertinoBackgroundColor,
                  child: Row(
                    children: [
                      _buildSkipBack(iconColor, barHeight),
                      _buildPlayPause(iconColor, barHeight),
                      _buildSkipForward(iconColor, barHeight),
                      _buildPosition(iconColor),
                      _buildProgressBar(),
                      _buildRemaining(iconColor)
                    ],
                  ))),
        ),
      ),
      // )
    );
  }

  Widget _buildProgressBar() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: buildVideoProgressBarAdapter(
          color: controlsConf.cupertinoProgressColors ??
              ProgressColors(
                playedColor: const Color.fromARGB(
                  120,
                  255,
                  255,
                  255,
                ),
                handleColor: const Color.fromARGB(
                  255,
                  255,
                  255,
                  255,
                ),
                bufferedColor: const Color.fromARGB(
                  60,
                  255,
                  255,
                  255,
                ),
                backgroundColor: const Color.fromARGB(
                  20,
                  255,
                  255,
                  255,
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildPosition(Color? iconColor) {
    final position = controller.value.position;
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Text(
        position.toString(),
        style: TextStyle(
          color: iconColor,
          fontSize: 12.0,
        ),
      ),
    );
  }

  Widget _buildRemaining(Color? iconColor) {
    final position = controller.value.duration - controller.value.position;
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Text(
        '-$position',
        style: TextStyle(color: iconColor, fontSize: 12.0),
      ),
    );
  }

  Widget _buildPlayPause(
    Color iconColor,
    double barHeight,
  ) {
    return Container(
      // color: Colors.transparent,
      margin: const EdgeInsets.only(
        left: 6.0,
        right: 6.0,
      ),
      child: GestureDetector(
        onTap: playPause,
        child: AnimatedPlayPause(
          color: iconColor,
          playing: controller.value.isPlaying,
        ),
      ),
    );
  }

  GestureDetector _buildSkipBack(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: skipBack,
      child: Container(
        height: barHeight,
        // color: Colors.transparent,
        margin: const EdgeInsets.only(left: 10.0),
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 6.0,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              CupertinoIcons.gobackward,
              color: iconColor,
              size: 18.0,
            ),
            const Text(
              '1',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector _buildSkipForward(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: skipForward,
      child: Container(
        height: barHeight,
        // color: Colors.transparent,
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 8.0,
        ),
        margin: const EdgeInsets.only(
          right: 8.0,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              CupertinoIcons.goforward,
              color: iconColor,
              size: 18.0,
            ),
            const Text(
              '1',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
