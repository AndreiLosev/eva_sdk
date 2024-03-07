import 'dart:convert';

import 'package:busrt_client/busrt_client.dart';
import 'package:eva_sdk/src/enums.dart';

class Logger {
  final Bus _bus;
  final LogLevel _minLevel;
  final _codec = Utf8Encoder();

  Logger(this._bus, this._minLevel);

  Future<void> trace(Iterable<Object> mess) async {
    if (_minLevel.lessOrequal(LogLevel.trace)) {
      await _log(LogLevel.trace, mess);
    }
  }

  Future<void> debug(Iterable<Object> mess) async {
    if (_minLevel.lessOrequal(LogLevel.debug)) {
      await _log(LogLevel.debug, mess);
    }
  }

  Future<void> info(Iterable<Object> mess) async {
    if (_minLevel.lessOrequal(LogLevel.info)) {
      await _log(LogLevel.info, mess);
    }
  }

  Future<void> warn(Iterable<Object> mess) async {
    if (_minLevel.lessOrequal(LogLevel.warn)) {
      await _log(LogLevel.warn, mess);
    }
  }

  Future<void> error(Iterable<Object> mess) async {
    if (_minLevel.lessOrequal(LogLevel.error)) {
      await _log(LogLevel.error, mess);
    }
  }

  Future<void> _log(LogLevel level, Iterable<Object> mess) async {
    final prepared = mess.map((e) => e.toString()).join(" ");
    await _bus.publish(
      EapiTopic.logInputTopic.resolve(level.toString()),
      _codec.convert(prepared),
      QoS.no,
    );
  }
}
