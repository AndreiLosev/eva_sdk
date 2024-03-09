enum LogLevel {
  trace,
  debug,
  info,
  warn,
  error;

  int code() => switch (this) {
        LogLevel.trace => 0,
        LogLevel.debug => 10,
        LogLevel.info => 20,
        LogLevel.warn => 30,
        LogLevel.error => 40,
      };

  @override
  String toString() => switch (this) {
        LogLevel.trace => 'trace',
        LogLevel.debug => 'debug',
        LogLevel.info => 'info',
        LogLevel.warn => 'warn',
        LogLevel.error => 'error',
      };

  bool lessOrequal(LogLevel level) => code() <= level.code();
}

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

enum EvaErrorKind {
  notFound,
  accessDenied,
  systemError,
  other,
  notReady,
  unsupported,
  coreError,
  timeout,
  invalidData,
  funcFailed,
  aborted,
  alreadyExists,
  busy,
  methodNotImplemented,
  tokenRestricted,
  io,
  registry,
  evahiAuthRequired,
  accessDeniedMoreDataRequired,
  parse,
  invalidRequest,
  methodNotFound,
  invalidParams,
  rpcInternal,
  busClientNotRegistered,
  busData,
  busIo,
  busOther,
  busNotSupported,
  busBusy,
  busNotDelivered,
  busTimeout;

  int code() => switch (this) {
        EvaErrorKind.notFound => -32001,
        EvaErrorKind.accessDenied => -32002,
        EvaErrorKind.systemError => -32003,
        EvaErrorKind.other => -32004,
        EvaErrorKind.notReady => -32005,
        EvaErrorKind.unsupported => -32006,
        EvaErrorKind.coreError => -32007,
        EvaErrorKind.timeout => -32008,
        EvaErrorKind.invalidData => -32009,
        EvaErrorKind.funcFailed => -32010,
        EvaErrorKind.aborted => -32011,
        EvaErrorKind.alreadyExists => -32012,
        EvaErrorKind.busy => -32013,
        EvaErrorKind.methodNotImplemented => -32014,
        EvaErrorKind.tokenRestricted => -32015,
        EvaErrorKind.io => -32016,
        EvaErrorKind.registry => -32017,
        EvaErrorKind.evahiAuthRequired => -32018,
        EvaErrorKind.accessDeniedMoreDataRequired => -32022,
        EvaErrorKind.parse => -32700,
        EvaErrorKind.invalidRequest => -32600,
        EvaErrorKind.methodNotFound => -32601,
        EvaErrorKind.invalidParams => -32602,
        EvaErrorKind.rpcInternal => -32603,
        EvaErrorKind.busClientNotRegistered => -32113,
        EvaErrorKind.busData => -32114,
        EvaErrorKind.busIo => -32115,
        EvaErrorKind.busOther => -32116,
        EvaErrorKind.busNotSupported => -32117,
        EvaErrorKind.busBusy => -32118,
        EvaErrorKind.busNotDelivered => -32119,
        EvaErrorKind.busTimeout => -32120,
      };
}

extension ToEvaErrorKind on int {
  EvaErrorKind toEvaErrorKind() => switch (this) {
        -32001 => EvaErrorKind.notFound,
        -32002 => EvaErrorKind.accessDenied,
        -32003 => EvaErrorKind.systemError,
        -32004 => EvaErrorKind.other,
        -32005 => EvaErrorKind.notReady,
        -32006 => EvaErrorKind.unsupported,
        -32007 => EvaErrorKind.coreError,
        -32008 => EvaErrorKind.timeout,
        -32009 => EvaErrorKind.invalidData,
        -32010 => EvaErrorKind.funcFailed,
        -32011 => EvaErrorKind.aborted,
        -32012 => EvaErrorKind.alreadyExists,
        -32013 => EvaErrorKind.busy,
        -32014 => EvaErrorKind.methodNotImplemented,
        -32015 => EvaErrorKind.tokenRestricted,
        -32016 => EvaErrorKind.io,
        -32017 => EvaErrorKind.registry,
        -32018 => EvaErrorKind.evahiAuthRequired,
        -32022 => EvaErrorKind.accessDeniedMoreDataRequired,
        -32700 => EvaErrorKind.parse,
        -32600 => EvaErrorKind.invalidRequest,
        -32601 => EvaErrorKind.methodNotFound,
        -32602 => EvaErrorKind.invalidParams,
        -32603 => EvaErrorKind.rpcInternal,
        -32113 => EvaErrorKind.busClientNotRegistered,
        -32114 => EvaErrorKind.busData,
        -32115 => EvaErrorKind.busIo,
        -32116 => EvaErrorKind.busOther,
        -32117 => EvaErrorKind.busNotSupported,
        -32118 => EvaErrorKind.busBusy,
        -32119 => EvaErrorKind.busNotDelivered,
        -32120 => EvaErrorKind.busTimeout,
        _ => throw Exception("code $this in not EvaErrorKind"),
      };
}

enum EapiTopic {
  rawStateTopic,
  localStateTopic,
  remoteStateTopic,
  remoteArchiveStateTopic,
  anyStateTopic,
  replicationStateTopic,
  replicationInventoryTopic,
  replicationNodeStateTopic,
  logInputTopic,
  logEventTopic,
  logCallTraceTopic,
  serviceStatusTopic,
  aaaAclTopic,
  aaaKeyTopic,
  aaaUserTopic,
  actionStatus;

  String resolve([String topic = ""]) {
    return switch (this) {
      rawStateTopic => 'RAW/$topic',
      localStateTopic => 'ST/LOC/$topic',
      remoteStateTopic => 'ST/REM/$topic',
      remoteArchiveStateTopic => 'ST/RAR/$topic',
      anyStateTopic => 'ST/+/$topic',
      replicationStateTopic => 'RPL/ST/$topic',
      replicationInventoryTopic => 'RPL/INVENTORY/$topic',
      replicationNodeStateTopic => 'RPL/NODE/$topic',
      logInputTopic => 'LOG/IN/$topic',
      logEventTopic => 'LOG/EV/$topic',
      logCallTraceTopic => 'LOG/TR/$topic',
      serviceStatusTopic => 'SVC/ST/$topic',
      aaaAclTopic => 'AAA/ACL/$topic',
      aaaKeyTopic => 'AAA/KEY/$topic',
      aaaUserTopic => 'AAA/USER/$topic',
      actionStatus => 'ACT/$topic',
    };
  }
}

enum ServicePayloadKind {
  initial,
  ping;

  int code() => switch (this) {
        ServicePayloadKind.initial => 1,
        ServicePayloadKind.ping => 0,
      };

  bool isInitial() => this == ServicePayloadKind.initial;

  bool isPing() => this == ServicePayloadKind.ping;
}

extension ToServicePayloadKind on int {
  ServicePayloadKind toServicePayloadKind() => switch (this) {
        0 => ServicePayloadKind.ping,
        1 => ServicePayloadKind.initial,
        _ => throw Exception("$this in not ServicePayloadKind"),
      };
}

enum ServiceStatus {
  ready,
  terminating;

  @override
  String toString() => switch (this) {
        ServiceStatus.ready => 'ready',
        ServiceStatus.terminating => 'terminating',
      };
}

enum ActionStatus {
  created,
  accepted,
  pending,
  running,
  completed,
  failed,
  canceled,
  terminated;

  int code() => switch (this) {
        ActionStatus.created => 0,
        ActionStatus.accepted => 1,
        ActionStatus.pending => 2,
        ActionStatus.running => 8,
        ActionStatus.completed => 15,
        ActionStatus.failed => 128,
        ActionStatus.canceled => 129,
        ActionStatus.terminated => 130,
      };
}

extension AoActionsStatus on int {
  ActionStatus toActionsStatus() => switch (this) {
        0 => ActionStatus.created,
        1 => ActionStatus.accepted,
        2 => ActionStatus.pending,
        8 => ActionStatus.running,
        15 => ActionStatus.completed,
        128 => ActionStatus.failed,
        129 => ActionStatus.canceled,
        130 => ActionStatus.terminated,
        _ => throw Exception("$this in not ActionStatus"),
      };
}

enum ItemKind {
  unit,
  sensor,
  lVar,
  lMacro,
  any;

  @override
  String toString() => switch (this) {
        ItemKind.unit => "unit",
        ItemKind.sensor => "sensor",
        ItemKind.lVar => "lvar",
        ItemKind.lMacro => "lmacro",
        ItemKind.any => "+",
      };
}

extension ToItemKind on String {
  ItemKind toItemKind() => switch (this) {
        "unit" => ItemKind.unit,
        "sensor" => ItemKind.sensor,
        "lvar" => ItemKind.lVar,
        "imacro" => ItemKind.lMacro,
        "+" => ItemKind.any,
        _ => throw Exception("invalid item kind: $this"),
      };
}
