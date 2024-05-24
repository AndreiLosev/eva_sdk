import 'dart:convert';

import 'package:eva_sdk/src/enum/action_status.dart';
import 'package:eva_sdk/src/oid.dart';

class BusActionStatus {
  final List<int> uuid;
  final ActionStatus status;
  final Object? out;
  final Object? err;
  final int? exitcode;

  BusActionStatus(
    this.uuid,
    this.status, [
    this.out,
    this.err,
    this.exitcode,
  ]);

  BusActionStatus.fromMap(Map<String, Object?> map)
      : uuid = (map['uuid'] as List).cast(),
        status = (map['status'] as int).toActionsStatus(),
        out = map['out'],
        err = map['err'],
        exitcode = map['exitcode'] as int;

  Map<String, Object?> toMap() {
    return {
      'uuid': uuid,
      'status': status.code(),
      'out': out,
      'err': err,
      'exitcode': exitcode,
    };
  }
}

class ActionParams {
  final Object? value;
  final List<Object>? args;
  final Map<String, Object>? kwargs;

  ActionParams({
    this.value,
    this.args,
    this.kwargs,
  });

  ActionParams.fromMap(Map<String, dynamic> map)
      : value = map['value'],
        args = map['args'],
        kwargs = map['kwargs'];
}

class Action {
  final String uuid;
  final Oid oid;
  final Duration timeout;
  final int priority;
  final ActionParams? params;
  final Map<String, Object?>? config;

  Action(Map<String, dynamic> params)
      : uuid = Utf8Decoder().convert(params['uuid']),
        oid = Oid(params['i']),
        timeout = Duration(microseconds: params['timeout']),
        priority = params['priority'],
        params = ActionParams.fromMap(params['params']),
        config = params['config'];
}
