
class InitialPayload {
  final int version;
  final String systemName;
  final String id;
  final String command;
  final String? prepareCommand;
  final String? dataPath;
  final InitialTimeoutConfig timeout;
  final InitialCoreInfo core;
  final InitialBusConfig bus;
  final Map<String, dynamic> config;
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

  InitialPayload.fromMap(Map<String, dynamic> map)
      : version = map['version'],
        systemName = map['system_name'],
        id = map['id'],
        command = map['command'],
        prepareCommand = map['prepare_command'],
        dataPath = map['data_path'],
        timeout = InitialTimeoutConfig.fromMap(map['timeout']),
        core = InitialCoreInfo.fromMap(map['core']),
        bus = InitialBusConfig.fromMap(map['bus']),
        config = map['config'],
        workers = map['workers'],
        reactToFail = map['react_to_fail'],
        fips = map['fips'] ?? false,
        failMode = map['react_to_fail'],
        user = map['user'],
        callTracing = map['call_tracing'] ?? false;

  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'system_name': systemName,
      'id': id,
      'command': command,
      'prepare_command': prepareCommand,
      'data_path': dataPath,
      'timeout': timeout.toMap(),
      'core': core.toMap(),
      'bus': bus.toMap(),
      'config': config,
      'workers': workers,
      'react_to_fail': reactToFail,
      'fips': fips,
      'fail_mode': failMode,
      'user': user,
      'call_tracing': callTracing,
    };
  }
}

class InitialBusConfig {
  final String type;
  final String path;
  final Duration? timeout;
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
      : type = map['type'] ?? 'native',
        path = map['path'],
        timeout = _fromDoubleSeconds(map['timeout'] as double?),
        bufSize = map['buf_size'] ?? 0xffffffff,
        bufTtl = map['buf_ttl'] ?? 0xffffffff,
        queueSize = map['queue_size'] ?? 0xffffffff;

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'path': path,
      'timeout': timeout != null ? timeout!.inMilliseconds / 1000 : null,
      'buf_size': bufSize,
      'buf_ttl': bufTtl,
      'queue_size': queueSize,
    };
  }
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

  Map<String, dynamic> toMap() {
    return {
      'build': build,
      'version': version,
      'eapi_version': eapiVersion,
      'path': path,
      'log_level': logLevel,
      'active': active,
    };
  }
}

class InitialTimeoutConfig {
   final Duration? startup;
  final Duration? shutdown;
  final Duration default1;

  InitialTimeoutConfig.fromMap(Map<String, Object?>? map)
      : startup = _fromDoubleSeconds(map?['startup'] as double?),
        shutdown = _fromDoubleSeconds(map?['shutdown'] as double?),
        default1 = _fromDoubleSeconds((map?['default'] as double?) ?? 5)!;

  Map<String, dynamic> toMap() {
    return {
      'startup': startup != null ? startup!.inMilliseconds / 1000 : null,
      'shutdown': shutdown != null ? shutdown!.inMilliseconds / 1000 : null,
      'default': default1.inMilliseconds,
    };
  }
}

Duration? _fromDoubleSeconds(double? sec) {
    if (sec == null) {
      return null;
    }
    final seconds = sec.toInt();
    final miliseconds = ((sec - seconds) * 1000).toInt();

    return Duration(seconds: seconds, milliseconds: miliseconds);
  }
