import 'package:eva_sdk/src/enums.dart';

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
