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
    final backgroundColor =
        Theme.of(context).textTheme.bodyLarge!.backgroundColor;
    // if (controller.isFullScreen) {}
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        MediaQueryData mediaQueryData = MediaQuery.of(context);
        bool needFix = false;
        BoxConstraints fixConstraints = constraints;
        Size fixSize = controller.value.size.isEmpty
            ? mediaQueryData.size
            : controller.value.size;
        if (!constraints.hasBoundedHeight || !constraints.hasBoundedWidth) {
          if (constraints.hasBoundedWidth) {
            double height =
                constraints.maxWidth * fixSize.height / fixSize.width;
            fixConstraints = BoxConstraints.expand(
                width: fixConstraints.maxWidth, height: height);
          } else if (constraints.hasBoundedHeight) {
            double width =
                constraints.maxHeight * fixSize.width / fixSize.height;
            fixConstraints = BoxConstraints.expand(
                width: width, height: fixConstraints.maxHeight);
          } else {
            fixConstraints = BoxConstraints.expand(
                width: fixSize.width, height: fixSize.height);
          }
          needFix = true;
        }
        // debugPrint('fixConstraints:$fixConstraints');
        return Center(
          child: Container(
            color: needFix
                ? Colors.transparent
                : (controller.backgroundColor ?? backgroundColor),
            constraints: fixConstraints,
            child: _buildPlayerControls(
                context,
                Size(fixConstraints.maxWidth, fixConstraints.maxHeight),
                controller),
          ),
        );
      },
    );
  }

  Widget _buildPlayerControls(BuildContext context, Size size,
      GifPlayerController gifPlayerController) {
    if (!gifPlayerController.value.isInitialized) {
      return gifPlayerController.placeholder ?? Container();
    }
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
                width: size.width,
                height: size.height,
                fit: imageConfiguration.fit,
                colorBlendMode: imageConfiguration.colorBlendMode,
                alignment: imageConfiguration.alignment,
                repeat: imageConfiguration.repeat,
                centerSlice: imageConfiguration.centerSlice,
                matchTextDirection: imageConfiguration.matchTextDirection,
                invertColors: imageConfiguration.invertColors,
                filterQuality: imageConfiguration.filterQuality,
                isAntiAlias: imageConfiguration.isAntiAlias);
          },
        ),
        Positioned.fill(
          child: _buildControls(context, gifPlayerController),
        )
      ],
    );
  }

  Widget _buildControls(
      BuildContext context, GifPlayerController gifPlayerController) {
    if (gifPlayerController.showControls) {
      return gifPlayerController.customControls ?? _controlsAdapter(context);
    }
    return const SizedBox();
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
      default:
        return const MaterialControls();
    }
  }
}
