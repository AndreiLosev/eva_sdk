import 'dart:convert';

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

  InitialPayload.fromMap(
      Map<String, dynamic> map, T Function(Map<String, dynamic>) createConfig)
      : version = map['version'],
        systemName = map['system_name'],
        id = map['id'],
        command = map['command'],
        prepareCommand = map['prepare_command'],
        dataPath = map['dataPath'],
        timeout = InitialTimeoutConfig.fromMap(map['timeout']),
        core = InitialCoreInfo.fromMap(map['core']),
        bus = InitialBusConfig.fromMap(map['bus']),
        config = createConfig(map['config']),
        workers = map['workers'],
        reactToFail = map['react_to_fail'],
        fips = map['fips'],
        failMode = map['fail_mode'],
        user = map['user'],
        callTracing = map['call_tracing'];
}

class InitialTimeoutConfig {
  final Duration? startup;
  final Duration? shutdown;
  final Duration? default1;

  InitialTimeoutConfig.fromMap(Map<String, Object?> map)
      : startup = _fromDoubleSeconds(map['startup'] as double?),
        shutdown = _fromDoubleSeconds(map['shutdown'] as double?),
        default1 = _fromDoubleSeconds(map['default'] as double?);

  static Duration? _fromDoubleSeconds(double? sec) {
    if (sec == null) {
      return null;
    }
    final seconds = sec.toInt();
    final miliseconds = ((sec - seconds) * 1000).toInt();

    return Duration(seconds: seconds, milliseconds: miliseconds);
  }
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

  InitialBusConfig.fromMap(Map<String, dynamic> map)
      : type = map['type'],
        path = map['path'],
        timeout = map['timeout'],
        bufSize = map['buf_size'],
        bufTtl = map['buf_ttl'],
        queueSize = map['queue_size'];
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

  InitialCoreInfo.fromMap(Map<String, dynamic> map)
      : build = map['build'],
        version = map['version'],
        eapiVersion = map['eapi_version'],
        path = map['path'],
        logLevel = map['log_level'],
        active = map['active'];
}

class ServiceMethodParam {
  final String name;
  final String type;
  final String description;
  final bool required;

  ServiceMethodParam(this.name, this.type, this.required,
      [this.description = '']);

  Map<String, dynamic> toMap() => {
        'name': name,
        'type': type,
        'description': description,
        'required': required,
      };
}

class ServiceMethod {
  final String name;
  final String description;
  final List<ServiceMethodParam> params = [];

  ServiceMethod(this.name, [this.description = ""]);

  void required(String name, String type, [String description = ""]) =>
      params.add(ServiceMethodParam(name, type, true, description));

  void optional(String name, String type, [String description = ""]) =>
      params.add(ServiceMethodParam(name, type, false, description));

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'params': params.map((e) => e.toMap()),
      };
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

  Map<String, dynamic> toMap() => {
        'author': author,
        'description': description,
        'version': version,
        'methods': methods.map((e) => e.toMap()),
      };
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
  final List<int> uuid;
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
