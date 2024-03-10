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
      : type = map['type'],
        path = map['path'],
        timeout = map['timeout'] is int ? Duration(seconds: map['timeout']) : null,
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

class InitialTimeoutConfig {
  final Duration? startup;
  final Duration? shutdown;
  final Duration default1;

  InitialTimeoutConfig.fromMap(Map<String, Object?> map)
      : startup = _fromDoubleSeconds(map['startup'] as double?),
        shutdown = _fromDoubleSeconds(map['shutdown'] as double?),
        default1 = _fromDoubleSeconds(map['default'] as double)!;

  static Duration? _fromDoubleSeconds(double? sec) {
    if (sec == null) {
      return null;
    }
    final seconds = sec.toInt();
    final miliseconds = ((sec - seconds) * 1000).toInt();

    return Duration(seconds: seconds, milliseconds: miliseconds);
  }
}
