# gif_player
[![Pub](https://img.shields.io/pub/v/gif_player.svg?style=flat-square)](https://pub.dev/packages/gif_player)
[![support](https://img.shields.io/badge/platform-android%20|%20ios%20|%20web%20|%20macos%20|%20windows%20|%20linux%20-blue.svg)](https://pub.dev/packages/gif_player)

The GIF player Flutter package offers functionality for playing, pausing, and seeking within GIFs, accompanied by a progress bar for playback control. With this package, users can seamlessly enjoy GIF animations, controlling playback as desired by pausing, resuming, and jumping to specific points within the animation. The progress bar provides visual feedback on the current playback position, allowing users to track their progress and navigate through the GIF with ease.

## Preview

![](https://github.com/meetleev/static_resources/blob/main/gif_player/gif_player.gif)

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  gif_player: <latest_version>
```

## Features
* Support play, pause, seek
* Support loop play
* Support progressbar or custom progressbar
* support gif player event.

## Usage
``` dart
// init
GifPlayerController controller = GifPlayerController(
        backgroundColor: Colors.black,
        dataSource: GifPlayerDataSource.asset(assetGifUrl));

// build
GifPlayer(controller: controller, fit: BoxFit.fill),
```
