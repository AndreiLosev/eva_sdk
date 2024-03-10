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

extension CodeToLogLevel on int {
  LogLevel toLogLevel() => switch (this) {
        0 => LogLevel.trace,
        10 => LogLevel.debug,
        20 => LogLevel.info,
        30 => LogLevel.warn,
        40 => LogLevel.error,
        _ => throw Exception("$this is not LogLevelCode"),
      };
}
