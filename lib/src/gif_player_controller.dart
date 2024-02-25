import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gif_player/src/events/player_event_type.dart';
import 'package:http/http.dart' as http;

import 'configuration/controls_configuration.dart';
import 'configuration/data_source.dart';
import 'constants.dart';
import 'events/player_event.dart';

class GifPlayerValue {
  /// Indicates whether or not the gif has been loaded and is ready to play.
  final bool isInitialized;

  /// The total duration of the gif.
  final int duration;

  /// The current playback position.
  final int position;

  /// True if the gif is playing. False if it's paused.
  final bool isPlaying;

  /// True if the gif is looping.
  final bool isLooping;

  /// True if gif has finished playing to end.
  final bool isCompleted;

  /// The [size] of the currently loaded gif.
  /// The size is [Size.zero] if the gif hasn't been initialized.
  final Size size;

  GifPlayerValue(
      {required this.duration,
      this.isInitialized = false,
      this.position = 0,
      this.isPlaying = false,
      this.isLooping = false,
      this.isCompleted = false,
      Size? size})
      : size = size ?? Size.zero;

  GifPlayerValue copyWith(
      {int? duration,
      int? position,
      bool? isInitialized,
      bool? isPlaying,
      bool? isLooping,
      bool? isCompleted,
      Size? size}) {
    return GifPlayerValue(
        duration: duration ?? this.duration,
        position: position ?? this.position,
        isInitialized: isInitialized ?? this.isInitialized,
        isPlaying: isPlaying ?? this.isPlaying,
        isLooping: isLooping ?? this.isLooping,
        isCompleted: isCompleted ?? this.isCompleted,
        size: size ?? this.size);
  }
}

const _defaultHideControlsTimer = Duration(seconds: 3);

class GifPlayerController extends ValueNotifier<GifPlayerValue> {
  final GifPlayerDataSource dataSource;

  /// The placeholder is displayed underneath the gif before it is initialized or played.
  final Widget? placeholder;

  /// Flag used to store full screen mode state.
  final bool _isFullScreen = false;

  /// Flag used to store full screen mode state.
  bool get isFullScreen => _isFullScreen;

  /// Whether or not to show the controls at all
  final bool showControls;

  /// Whether or not to show the playButton at all
  final bool showPlayButton;

  /// Defines customised controls. Check [MaterialControls] or
  /// [CupertinoControls] for reference.
  final Widget? customControls;

  /// Defines the [Duration] before the video controls are hidden. By default, this is set to three seconds.
  final Duration hideControlsTimer;

  /// The controlsConfiguration to use for the Material Progress Bar.
  final GifPlayerControlsConfiguration controlsConfiguration;

  /// Color of the background, when no frame is displayed.
  final Color? backgroundColor;

  /// Play the gif as soon as it's displayed
  final bool isAutoPlay;

  final StreamController _streamController = StreamController.broadcast();

  final List<FrameInfo> _gifFrames = [];

  GifPlayerController(
      {required this.dataSource,
      this.backgroundColor,
      this.placeholder,
      this.showControls = true,
      this.showPlayButton = true,
      this.customControls,
      this.isAutoPlay = true,
      bool isAutoInitialize = true,
      this.hideControlsTimer = _defaultHideControlsTimer,
      GifPlayerControlsConfiguration? controlsConf})
      : controlsConfiguration =
            controlsConf ?? GifPlayerControlsConfiguration(),
        super(GifPlayerValue(duration: 0)) {
    if (isAutoInitialize) {
      initialize();
    }
  }

  Stream<T> on<T>() {
    if (dynamic == T) {
      return _streamController.stream as Stream<T>;
    }
    return _streamController.stream.where((event) => event is T).cast<T>();
  }

  /// emit event
  void emit<T>(T event) {
    _streamController.add(event);
  }

  /// Listen on the given [listener].
  StreamSubscription<GifPlayerEvent> addPlayerEventListener(
      GifPlayerEventListener listener) {
    return on<GifPlayerEvent>().listen(listener);
  }

  Future<void> play() async {
    value = value.copyWith(isPlaying: true);
    await _runLoop();
    emit(GifPlayerEvent(eventType: GifPlayerEventType.play));
  }

  void pause() {
    value = value.copyWith(isPlaying: false);
    emit(GifPlayerEvent(eventType: GifPlayerEventType.pause));
  }

  Future<void> seekTo(int position) async {
    if (_isNeedFixPosition(position)) {
      position = _fixPosition(position);
    }
    value = value.copyWith(position: position);
    emit(GifPlayerEvent(eventType: GifPlayerEventType.seekTo, data: position));
  }

  void setLoop(bool loop) {
    value = value.copyWith(isLooping: loop);
  }

  Future<void> initialize() async {
    final Completer<void> initializeCompleter = Completer<void>();
    Uint8List? imageData;
    FlutterErrorDetails? error;
    switch (dataSource.type) {
      case GifPlayerDataSourceType.network:
        try {
          final response = await http.get(Uri.parse(dataSource.url),
              headers: dataSource.headers);
          if (HttpStatus.ok == response.statusCode) {
            imageData = response.bodyBytes;
            if (imageData.lengthInBytes == 0) {
              error = FlutterErrorDetails(
                  exception: 'gif is an empty file: ${dataSource.url}',
                  library: Constants.libraryName);
            }
          } else {
            error = FlutterErrorDetails(
                exception: 'http ${response.statusCode}',
                library: Constants.libraryName);
          }
        } catch (e, s) {
          error = FlutterErrorDetails(
              exception: e, stack: s, library: Constants.libraryName);
        }
        break;
      case GifPlayerDataSourceType.asset:
        try {
          final image = AssetImage(dataSource.url, package: dataSource.package);
          AssetBundleImageKey imageKey =
              await image.obtainKey(const ImageConfiguration());
          final data = await imageKey.bundle.load(imageKey.name);
          imageData = data.buffer.asUint8List();
        } catch (e, s) {
          error = FlutterErrorDetails(
              exception: e, stack: s, library: Constants.libraryName);
        }
        break;
      case GifPlayerDataSourceType.file:
        try {
          var file = File(dataSource.url);
          if (file.existsSync()) {
            imageData = await file.readAsBytes();
          } else {
            error = const FlutterErrorDetails(
                exception: 'file does not exists!',
                library: Constants.libraryName);
          }
        } catch (e, s) {
          error = FlutterErrorDetails(
              exception: e, stack: s, library: Constants.libraryName);
        }
        break;
    }
    if (null == imageData) {
      initializeCompleter.completeError(error ?? 'unknown error');
      return initializeCompleter.future;
    }
    Codec codec = await instantiateImageCodec(
      imageData,
      allowUpscaling: false,
    );
    _gifFrames.clear();
    Size? size;
    for (int i = 0; i < codec.frameCount; i++) {
      final imageInfo = await codec.getNextFrame();
      size ??= Size(
          imageInfo.image.width.toDouble(), imageInfo.image.height.toDouble());
      _gifFrames.add(imageInfo);
    }
    value = GifPlayerValue(
        duration: _gifFrames.length - 1,
        position: 0,
        isInitialized: true,
        size: size);
    emit(GifPlayerEvent(eventType: GifPlayerEventType.initialized));
    initializeCompleter.complete();
    if (isAutoPlay) {
      await play();
    }
    return initializeCompleter.future;
  }

  Future<void> _playNextFrame() async {
    await Future.delayed(currentFrame.duration);
    if (value.isPlaying) {
      if (value.position < value.duration) {
        value = value.copyWith(position: value.position + 1);
      } else if (value.isLooping) {
        value = value.copyWith(position: 0);
      } else {
        value = value.copyWith(isCompleted: true, isPlaying: false);
      }
    }
    await _runLoop();
  }

  Future<void> _runLoop() async {
    if (value.isPlaying) {
      await _playNextFrame();
    } else if (value.isCompleted) {
      emit(GifPlayerEvent(eventType: GifPlayerEventType.finished));
    }
  }

  FrameInfo get currentFrame {
    int pos = value.position;
    if (_isNeedFixPosition(pos)) {
      pos = _fixPosition(pos);
      value = value.copyWith(position: pos);
    }
    return _gifFrames[value.position];
  }

  bool _isNeedFixPosition(int position) {
    if (0 > position || value.duration < position) {
      return true;
    }
    return false;
  }

  int _fixPosition(int position) {
    if (0 > position) {
      return 0;
    }
    if (value.duration < position) {
      return value.duration;
    }
    return position;
  }

  @override
  void dispose() {
    pause();
    super.dispose();
  }

  static GifPlayerController of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<GifPlayerControllerProvider>()!;
    return provider.controller;
  }
}

class GifPlayerControllerProvider extends InheritedWidget {
  final GifPlayerController controller;

  const GifPlayerControllerProvider(
      {super.key, required super.child, required this.controller});

  @override
  bool updateShouldNotify(GifPlayerControllerProvider oldWidget) =>
      oldWidget.controller != controller;
}
