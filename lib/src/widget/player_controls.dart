import 'package:flutter/material.dart';

import '../configuration/image_configuration.dart';
import '../gif_player_controller.dart';
import 'cupertino_controls.dart';
import 'material_controls.dart';

class PlayerControls extends StatelessWidget {
  final GifPlayerController controller;
  final GifImageConfiguration imageConfiguration;

  const PlayerControls({
    super.key,
    required this.controller,
    required this.imageConfiguration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(child: _buildPlayerControls(context, controller));
  }

  Widget _buildPlayerControls(
    BuildContext context,
    GifPlayerController gifPlayerController,
  ) {
    if (!gifPlayerController.value.isInitialized) {
      return gifPlayerController.placeholder ?? Container();
    }
    final mediaQuery = MediaQuery.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        ListenableBuilder(
          listenable: gifPlayerController,
          builder: (BuildContext context, Widget? child) {
            return RawImage(
              image: gifPlayerController.currentFrame.image,
              scale: imageConfiguration.scale,
              color: imageConfiguration.color,
              opacity: imageConfiguration.opacity,
              width:
                  gifPlayerController.isFullScreen
                      ? mediaQuery.size.width
                      : null,
              height:
                  gifPlayerController.isFullScreen
                      ? mediaQuery.size.height
                      : null,
              fit: imageConfiguration.fit,
              colorBlendMode: imageConfiguration.colorBlendMode,
              alignment: imageConfiguration.alignment,
              repeat: imageConfiguration.repeat,
              centerSlice: imageConfiguration.centerSlice,
              matchTextDirection: imageConfiguration.matchTextDirection,
              invertColors: imageConfiguration.invertColors,
              filterQuality: imageConfiguration.filterQuality,
              isAntiAlias: imageConfiguration.isAntiAlias,
            );
          },
        ),
        Positioned.fill(child: _buildControls(context, gifPlayerController)),
      ],
    );
  }

  Widget _buildControls(
    BuildContext context,
    GifPlayerController gifPlayerController,
  ) {
    if (gifPlayerController.showControls) {
      return gifPlayerController.customControls ?? _controlsAdapter(context);
    }
    return const SizedBox.shrink();
  }

  Widget _controlsAdapter(BuildContext context) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return const MaterialControls();
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      // return const MaterialDesktopControls();
      case TargetPlatform.iOS:
        return const CupertinoControls();
    }
  }
}
