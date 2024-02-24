import 'player_event_type.dart';

typedef GifPlayerEventListener = void Function(GifPlayerEvent event);

class GifPlayerEvent {
  /// The type of the event. see [GifPlayerEventType]
  final GifPlayerEventType eventType;
  /// The data of the event.
  final Object? data;

  GifPlayerEvent({required this.eventType, this.data});
}
