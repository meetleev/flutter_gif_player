import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';

import '../configuration/controls_configuration.dart';
import '../events/player_event_type.dart';
import '../gif_player_controller.dart';
import '../events/player_event.dart';
import '../progress_colors.dart';
import 'center_play_button.dart';
import 'progress_bar_adapter.dart';

abstract class ControlsState<T extends StatefulWidget> extends State<T> {
  GifPlayerController? _controller;

  GifPlayerController get controller => _controller!;

  GifPlayerControlsConfiguration get controlsConf =>
      controller.controlsConfiguration;

  bool wasLoading = false;
  Timer? _hideControlsTimer;
  bool _dragging = false;
  bool controlsVisible = true;

  bool get isFinished {
    if (controller.value.isInitialized) {
      return controller.value.position >= controller.value.duration;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (null == _controller) {
      _controller = GifPlayerController.of(context);
      _initialize();
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    controller.addListener(_updateState);
    _updateState();
  }

  void _dispose() {
    controller.removeListener(_updateState);
    _hideControlsTimer?.cancel();
  }

  void _updateState() {
    if (mounted) {
      wasLoading = !controller.value.isInitialized;
      if (!isFinished) {
        if (!controller.value.isPlaying) {
          _hideControlsTimer?.cancel();
          changePlayerControlsVisible(true);
        }
        setState(() {});
      } else {
        _hideControlsTimer?.cancel();
        changePlayerControlsVisible(true);
      }
    }
  }

  void playPause() {
    setState(() {
      if (controller.value.isPlaying) {
        changePlayerControlsVisible(true);
        _hideControlsTimer?.cancel();
        controller.pause();
      } else {
        _restartControlsTimer();
        if (!controller.value.isInitialized) {
          controller.initialize().then((value) => controller.play());
        } else {
          if (isFinished) {
            controller.seekTo(0);
          }
          controller.play();
        }
      }
    });
  }

  void _restartControlsTimer() {
    _hideControlsTimer?.cancel();
    _startHideControlsTimer();
    changePlayerControlsVisible(true);
  }

  void _startHideControlsTimer() {
    final hideControlsTimer = controller.hideControlsTimer;
    _hideControlsTimer = Timer(hideControlsTimer, () {
      changePlayerControlsVisible(false);
    });
  }

  Widget buildMain({required Widget child}) {
    return GestureDetector(
      onTap: () => _restartControlsTimer(),
      child: child,
    );
  }

  Widget buildHitArea() {
    final bool showPlayButton =
        controller.showPlayButton && !controller.value.isPlaying && !_dragging;
    return GestureDetector(
      onTap: () {
        if (!controller.value.isInitialized) return;
        if (controller.value.isPlaying) {
          if (controlsVisible) {
            changePlayerControlsVisible(false);
          } else {
            _restartControlsTimer();
          }
        } else {
          playPause();
        }
      },
      child: CenterPlayButton(
        backgroundColor: controlsConf.cupertinoBackgroundColor,
        iconColor: controlsConf.cupertinoIconColor,
        isFinished: isFinished,
        isPlaying: controller.value.isPlaying,
        show: showPlayButton,
        onPressed: playPause,
      ),
    );
  }

  Widget buildVideoProgressBarAdapter({ProgressColors? color}) {
    return ProgressBarAdapter(
      controller,
      onDragStart: () {
        setState(() {
          _dragging = true;
        });
        _hideControlsTimer?.cancel();
      },
      onDragEnd: () {
        setState(() {
          _dragging = false;
        });
        _startHideControlsTimer();
      },
      colors: color,
    );
  }

  void skipForward() {
    _restartControlsTimer();
    final end = controller.value.duration;
    final skip = controller.value.position + 1;
    controller.seekTo(min(skip, end));
  }

  void skipBack() {
    _restartControlsTimer();
    final beginning = Duration.zero.inMilliseconds;
    final skip = controller.value.position - 1;
    controller.seekTo(max(skip, beginning));
  }

  /// Called when player controls visibility should be changed.
  void changePlayerControlsVisible(bool visible) {
    setState(() {
      controller.emit(GifPlayerEvent(
          eventType: GifPlayerEventType.controlsVisibleChange, data: visible));
      controlsVisible = visible;
    });
  }
}
