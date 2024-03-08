import 'dart:convert';
import 'dart:typed_data';

import 'package:eva_sdk/src/enums.dart';
import 'package:eva_sdk/src/oid.dart';

class EvaError {
  final EvaErrorKind code;
  final String? message;

  EvaError(this.code, this.message);

  @override
  String toString() => "$code: $message";
}

const itemStatusError = -1;

const sleepStep = 100;

class InitialPayload<T extends Object> {
  final int version;
  final String systemName;
  final String id;
  final String command;
  final String? prepareCommand;
  final String dataPath;
  final InitialTimeoutConfig timeout;
  final InitialCoreInfo core;
  final InitialBusConfig bus;
  final T config;
  final int workers;
  final String? user;
  final bool reactToFail;
  final bool failMode;
  final bool fips;
  final bool callTracing;

  InitialPayload(
    this.version,
    this.systemName,
    this.id,
    this.command,
    this.prepareCommand,
    this.dataPath,
    this.timeout,
    this.core,
    this.bus,
    this.config,
    this.workers,
    this.user,
    this.reactToFail,
    this.failMode,
    this.fips,
    this.callTracing,
  );
}

class InitialTimeoutConfig {
  final int startup;
  final int shutdown;
  final int default1;

  InitialTimeoutConfig(this.startup, this.shutdown, this.default1);
}

class InitialBusConfig {
  final String type;
  final String path;
  final int? timeout;
  final int bufSize;
  final int bufTtl;
  final int queueSize;

  InitialBusConfig(
    this.type,
    this.path,
    this.timeout,
    this.bufSize,
    this.bufTtl,
    this.queueSize,
  );
}

class InitialCoreInfo {
  final int build;
  final String version;
  final int eapiVersion;
  final String path;
  final int logLevel;
  final bool active;

  InitialCoreInfo(
    this.build,
    this.version,
    this.eapiVersion,
    this.path,
    this.logLevel,
    this.active,
  );
}

class ServiceMethod {
  final String name;
  final String description;
  final List<String> requiredParams = [];
  final List<String> optionalParams = [];

  ServiceMethod(this.name, [this.description = ""]);

  void required(String name) => requiredParams.add(name);

  void optional(String name) => optionalParams.add(name);
}

class ServiceInfo {
  final String author;
  final String description;
  final String version;
  final methods = <ServiceMethod>[];

  ServiceInfo(this.author, this.version, [this.description = ""]);

  void addMethod(ServiceMethod method) {
    methods.add(method);
  }
}

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

class BusAction {
  final Uint8List uuid;
  final String oid;
  final int timeout; // microseconds
  final int priority;
  final ActionParams? params;
  final Map<String, Object?>? config;

  BusAction(
    this.uuid,
    this.oid,
    this.timeout,
    this.priority, {
    this.params,
    this.config,
  });
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
}

class Action {
  final String uuid;
  final Oid oid;
  final Duration timeout;
  final int priority;
  final ActionParams? params;
  final Map<String, Object?>? config;

  Action(BusAction event)
      : uuid = Utf8Decoder().convert(event.uuid),
        oid = Oid(event.oid),
        timeout = Duration(microseconds: event.timeout),
        priority = event.priority,
        params = event.params,
        config = event.config;
}
