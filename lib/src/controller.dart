import 'dart:typed_data';

import 'package:busrt_client/busrt_client.dart';
import 'package:eva_sdk/src/dto/bus_action.dart';
import 'package:eva_sdk/src/enum/action_status.dart';
import 'package:eva_sdk/src/enum/eapi_topic.dart';
import 'package:msgpack_dart/msgpack_dart.dart';
import 'package:uuid/parsing.dart';

class Controller {
  final Bus _bus;

  Controller(this._bus);

  Future<void> eventPending(Action action) {
    return _sendEvent(action, ActionStatus.pending);
  }

  Future<void> eventRunning(Action action) {
    return _sendEvent(action, ActionStatus.running);
  }

  Future<void> eventFailed(Action action,
      {Object? out, Object? err, int? exitcode}) {
    return _sendEvent(action, ActionStatus.failed, out, err, exitcode ?? -1);
  }

  Future<void> eventCompleted(Action action, Object? out) {
    return _sendEvent(action, ActionStatus.completed, out, null, 0);
  }

  Future<void> eventCanceled(Action action) {
    return _sendEvent(action, ActionStatus.canceled);
  }

  Future<void> eventTerminated(Action action) {
    return _sendEvent(action, ActionStatus.pending);
  }

  Future<void> _sendEvent(Action action, ActionStatus status,
      [Object? out, Object? err, int? exitcode]) async {
    final path = action.oid.asPath();
    final payload =
        _actionEventPayload(action.uuid, status, out, err, exitcode);
    await _bus.publish(EapiTopic.actionStatus.resolve(path), payload, QoS.no);
  }

  Uint8List _actionEventPayload(String uuid, ActionStatus status,
          [Object? out, Object? err, int? exitcode]) =>
      serialize(BusActionStatus(
        UuidParsing.parse(uuid),
        status,
        out,
        err,
        exitcode,
      ).toMap());
}
