import 'package:eva_sdk/src/enum/eapi_topic.dart';

enum EventKind {
  any,
  local,
  remote,
  remoteArchive;

  @override
  String toString() => switch (this) {
        EventKind.any => 'any',
        EventKind.local => 'local',
        EventKind.remote => 'remote',
        EventKind.remoteArchive => 'remote_archive',
      };

  EapiTopic toEapiTopic() => switch (this) {
        EventKind.any => EapiTopic.anyStateTopic,
        EventKind.local => EapiTopic.logInputTopic,
        EventKind.remote => EapiTopic.remoteStateTopic,
        EventKind.remoteArchive => EapiTopic.remoteArchiveStateTopic,
      };
}

extension CodeToEventKind on String {
  EventKind toEventKind() {
    return switch (this) {
      'any' => EventKind.any,
      'local' => EventKind.local,
      'remote' => EventKind.remote,
      'remote_archive' => EventKind.remoteArchive,
      _ => throw Exception("$this is not EventKind"),
    };
  }
}
