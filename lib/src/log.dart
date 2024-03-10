import 'dart:convert';

import 'package:busrt_client/busrt_client.dart';
import 'package:eva_sdk/src/enum/eapi_topic.dart';
import 'package:eva_sdk/src/enum/log_level.dart';

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

  Future<void> debug(Object mess) async {
    if (_minLevel.lessOrequal(LogLevel.debug)) {
      await _log(LogLevel.debug, mess);
    }
  }

  Future<void> info(Object mess) async {
    if (_minLevel.lessOrequal(LogLevel.info)) {
      await _log(LogLevel.info, mess);
    }
  }

  Future<void> warn(Object mess) async {
    if (_minLevel.lessOrequal(LogLevel.warn)) {
      await _log(LogLevel.warn, mess);
    }
  }

  Future<void> error(Object mess) async {
    if (_minLevel.lessOrequal(LogLevel.error)) {
      await _log(LogLevel.error, mess);
    }
  }

  Future<void> _log(LogLevel level, Object mess) async {
    await _bus.publish(
      EapiTopic.logInputTopic.resolve(level.toString()),
      _codec.convert(mess.toString()),
      QoS.no,
    );
  }
}
