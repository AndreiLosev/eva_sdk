import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:busrt_client/busrt_client.dart';
import 'package:eva_sdk/src/const_and_dto.dart';
import 'package:eva_sdk/src/controller.dart';
import 'package:eva_sdk/src/enums.dart';
import 'package:eva_sdk/src/log.dart';
import 'package:msgpack_dart/msgpack_dart.dart';
import 'package:typed_data/typed_data.dart';

class _ServiceState {
  bool active = true;
  bool loaded = false;
  bool privilegesDropped = false;
  bool shutdownRequested = false;
  bool markedReady = false;
  bool markedTerminating = false;
}

class Service {
  late final InitialPayload _initPaload;
  late final Rpc _rpc;
  late final Controller _controller;
  late final ServiceInfo _serviceInfo;
  late final Logger _logger;
  late Uint8List _svcInfoPacked;

  final _serviceState = _ServiceState();
  final _stdinBuffer = Uint8Buffer();
  StreamSubscription<List<int>>? _stdintSubscription;

  Service();

  Future<void> load<T extends Object>(
      T Function(Map<String, dynamic>) createConfig) async {
    if (_serviceState.loaded) {
      throw Exception("the service is already loaded");
    }

    _stdintSubscription = stdin.listen((e) => _stdinBuffer.addAll(e));

    var buf = await _stdinRead(1);

    if (!buf.first.toServicePayloadKind().isInitial()) {
      throw Exception("invalid payload");
    }

    buf = await _stdinRead(4);
    final dataLen = buf.buffer.asUint32List().first;

    buf = await _stdinRead(dataLen);
    final Map<String, dynamic> inital = deserialize(buf);
    _initPaload = InitialPayload.fromMap(inital, createConfig);
    _serviceState.loaded = true;

    //TODO set enviroment

    if (_initPaload.failMode && !_initPaload.reactToFail) {
      throw Exception(
          "the service is started in react-to-fail mode, but rtf is not supported by the service");
    }

    if (_initPaload.prepareCommand != null) {
      await Process.run(_initPaload.prepareCommand!, const []);
    }

    _stdintSubscription?.onDone(() async {
      _stdintSubscription?.cancel();
      await markTerminating();
    });

    _stdintSubscription?.onError((e) async {
      await _logger.error([e]);
      _stdintSubscription?.cancel();
      await markTerminating();
    });
    Future.microtask(() => _handleStdin());
  }

  Future<void> markTerminating() async {
    _serviceState.active = false;
    _serviceState.shutdownRequested = true;

    if (!_serviceState.markedTerminating) {
      _serviceState.markedTerminating = true;
      await _mark(ServiceStatus.terminating);
    }
  }

  void needReady() {
    if (!_serviceState.active) {
      throw EvaError(EvaErrorKind.rpcInternal, "service not ready");
    }
  }

  T getConfig<T extends Object>() => _initPaload.config as T;

  bool isModeNoraml() => !_initPaload.failMode;

  bool isModeRTF() => _initPaload.failMode;

  Future<Uint8List> _stdinRead(int len) async {
    while (_stdinBuffer.length < len) {
      if (_stdintSubscription == null) {
        throw Exception("_stdintSubscription = null");
      }
      await Future.delayed(Duration.zero);
    }

    final buf = Uint8List.fromList(_stdinBuffer.take(len).toList());
    _stdinBuffer.removeRange(0, len);

    return buf;
  }

  Future<void> _handleStdin() async {
    while (_serviceState.active) {
      final buf = await _stdinRead(1);
      if (!buf[0].toServicePayloadKind().isPing()) await markTerminating();
    }
  }

  Future<void> _mark(ServiceStatus status) async {
    await _rpc.bus.publish(
      EapiTopic.serviceStatusTopic.resolve(),
      serialize({'status': status.toString()}),
      QoS.no,
    );
  }

  String? _dataPath() =>
      _initPaload.user != 'nobody' ? _initPaload.dataPath : null;
}
