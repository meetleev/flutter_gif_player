import 'package:flutter/widgets.dart';
import 'configuration/image_configuration.dart';
import 'events/player_event.dart';
import 'events/player_event_type.dart';
import 'widget/player_controls.dart';
import 'gif_player_controller.dart';

class GifPlayer extends StatefulWidget {
  /// the controller of GifPlayer.
  final GifPlayerController controller;

  /// see [RawImage] for the following parameters.
  final double scale;
  final Color? color;
  final Animation<double>? opacity;
  final BoxFit? fit;
  final BlendMode? colorBlendMode;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Rect? centerSlice;
  final bool matchTextDirection;
  final bool invertColors;
  final FilterQuality filterQuality;

  final bool isAntiAlias;

  const GifPlayer(
      {super.key,
      required this.controller,
      this.scale = 1.0,
      this.color,
      this.opacity,
      this.colorBlendMode,
      this.fit,
      this.alignment = Alignment.center,
      this.repeat = ImageRepeat.noRepeat,
      this.centerSlice,
      this.matchTextDirection = false,
      this.invertColors = false,
      this.filterQuality = FilterQuality.low,
      this.isAntiAlias = false});

  @override
  State<GifPlayer> createState() => GifPlayerState();
}

class GifPlayerState extends State<GifPlayer> {
  @override
  void initState() {
    widget.controller.addPlayerEventListener(_onPlayerEvent);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GifPlayerControllerProvider(
        controller: widget.controller,
        child: PlayerControls(
          controller: widget.controller,
          imageConfiguration: GifImageConfiguration(
              scale: widget.scale,
              color: widget.color,
              opacity: widget.opacity,
              colorBlendMode: widget.colorBlendMode,
              fit: widget.fit,
              alignment: widget.alignment,
              repeat: widget.repeat,
              centerSlice: widget.centerSlice,
              matchTextDirection: widget.matchTextDirection,
              invertColors: widget.invertColors,
              filterQuality: widget.filterQuality,
              isAntiAlias: widget.isAntiAlias),
        ));
  }

  @override
  void didUpdateWidget(GifPlayer oldWidget) {
    if (oldWidget.controller != widget.controller) {
      widget.controller.addPlayerEventListener(_onPlayerEvent);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  void _onPlayerEvent(GifPlayerEvent event) {
    if (GifPlayerEventType.initialized == event.eventType) {
      setState(() {});
    }
  }
}
