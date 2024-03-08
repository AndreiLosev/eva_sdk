import 'dart:convert';
import 'dart:typed_data';

import 'package:busrt_client/busrt_client.dart';
import 'package:eva_sdk/src/const_and_dto.dart';
import 'package:eva_sdk/src/enums.dart';
import 'package:eva_sdk/src/helpers.dart';
import 'package:msgpack_dart/msgpack_dart.dart';

class Controller {
  final Bus _bus;
  final _utf8encoder = Utf8Encoder();
  final _serializer = Serializer();

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
    final payload = _actionEventPayload(action.uuid, status, out, err, exitcode);
    await _bus.publish(EapiTopic.actionStatus.resolve(path), payload, QoS.no);
  }

  Uint8List _actionEventPayload(String uuid, ActionStatus status,
      [Object? out, Object? err, int? exitcode]) {
    return _serializer.puck(BusActionStatus(
      _utf8encoder.convert(uuid).toList(),
      status,
      out,
      err,
      exitcode,
    ).toMap());
  }
}
