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
