import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:busrt_client/busrt_client.dart';
import 'package:eva_sdk/src/controller.dart';
import 'package:eva_sdk/src/dto/eva_error.dart';
import 'package:eva_sdk/src/dto/initial_payload.dart';
import 'package:eva_sdk/src/dto/service_info.dart';
import 'package:eva_sdk/src/enum/eapi_topic.dart';
import 'package:eva_sdk/src/enum/eva_error_kind.dart';
import 'package:eva_sdk/src/enum/event_kind.dart';
import 'package:eva_sdk/src/enum/log_level.dart';
import 'package:eva_sdk/src/enum/service_payload_kind.dart';
import 'package:eva_sdk/src/enum/service_status.dart';
import 'package:eva_sdk/src/helpers.dart';
import 'package:eva_sdk/src/log.dart';
import 'package:eva_sdk/src/oid.dart';
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
  
  static Service? _instanse;

  late final InitialPayload _initPaload;
  late final Rpc _rpc;
  late final Controller _controller;
  late final ServiceInfo _serviceInfo;
  late final Logger _logger;

  final _serviceState = _ServiceState();
  final _stdinBuffer = Uint8Buffer();
  StreamSubscription<List<int>>? _stdintSubscription;

  Service._();

  factory Service.getInstanse() {
    _instanse ??= Service._();

    return _instanse!;
  }

  Rpc get rpc => _rpc;
  Controller get controller => _controller;
  Logger get logger => _logger;

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
      await _logger.error(e);
      _stdintSubscription?.cancel();
      await markTerminating();
    });
    Future.microtask(() => _handleStdin());
  }

  Future<void> waitCore() async {
    final timer = Stopwatch();
    timer.stop();
    final timeout = _initPaload.timeout.startup ?? _initPaload.timeout.default1;

    while (_serviceState.active) {
      try {
        final req = await _rpc.call('eva.core', 'test');
        final result = await req.waitCompleted();

        if (deserialize(result!.payload)['active'] == true) {
          return;
        }
      } catch (_) {}
      if (timer.elapsed >= timeout) {
        throw Exception("core wait timeout");
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
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

  Future<void> init(ServiceInfo info,
      [FutureOr<void> Function(Frame f)? onFrame]) async {
    //TODO dropPrivileges
    final bus = await _initBus();
    _logger = Logger(bus, _initPaload.core.logLevel.toLogLevel());
    _controller = Controller(bus);
    _serviceInfo = info;
    _rpc = Rpc(bus, onCall: _handleRpcCall);

    if (onFrame != null) {
      _rpc.onFrame = onFrame;
    }

    _registerSignals();
    await _markReady();

    Timer(Duration.zero, () async {
      while (_serviceState.active) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      await markTerminating();
    });
  }

  Future<void> subscribeOIDs(Iterable<Oid> items, EventKind kind) async {
    final sfx = kind.toEapiTopic();
    final topics = items.map((e) => sfx.resolve(e.asPath())).toList();
    await _rpc.bus.subscribe(topics);
  }

  bool isActive() => _serviceState.active;

  bool isShutdownRequested() => _serviceState.shutdownRequested;

  Duration getTimeout() => _initPaload.timeout.default1;

  Future<void> _markReady() async {
    if (_serviceState.markedReady) {
      return;
    }

    _serviceState.markedReady = true;
    await _mark(ServiceStatus.ready);
    await _logger.info("${_serviceInfo.description} started");
  }

  void _registerSignals() {
    ProcessSignal.sigint.watch().listen((_) => _serviceState.active = false);
    ProcessSignal.sigterm.watch().listen((_) => _serviceState.active = false);
  }

  Future<Bus> _initBus() async {
    if (_initPaload.bus.type != 'native') {
      throw Exception("bus ${_initPaload.bus.type} is not suported");
    }

    final bus = Bus(_initPaload.id,
        timeout: _initPaload.bus.timeout ?? _initPaload.timeout.default1);
    await bus.connect(_initPaload.bus.path);

    return bus;
  }

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

  FutureOr<Uint8List?> _handleRpcCall(RpcEvent e) async {
    if (e.method == null) {
      noRpcMethod(e.method);
    }

    return switch (e.method!) {
      "test" => serialize({'status': _serviceState.active}),
      "info" => serialize(_serviceInfo.toMap()),
      "stop" => () {
          _serviceState.active = false;
          return null;
        }(),
      _ => _rpcCallWrapper(e.method!, e),
    };
  }

  FutureOr<Uint8List?> _rpcCallWrapper(String methodName, RpcEvent e) async {
    try {
      final ServiceMethod method =
          _serviceInfo.methods.firstWhere((i) => i.name == methodName);
      return await method.fn(e);
    } on StateError {
      noRpcMethod(methodName);
      return null;
    }
  }
}
