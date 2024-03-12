import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:busrt_client/busrt_client.dart';
import 'package:eva_sdk/src/controller.dart';
import 'package:eva_sdk/src/debug_log.dart';
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
import 'package:eva_sdk/src/item_state.dart';
import 'package:eva_sdk/src/log.dart';
import 'package:eva_sdk/src/oid.dart';
import 'package:msgpack_dart/msgpack_dart.dart';
import 'package:typed_data/typed_data.dart';

typedef SubscriptionHandler = FutureOr<void> Function(
    ItemState payload, String topic, String sender);

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

  final _subscriptionHandlers = <String, SubscriptionHandler>{};

  final _serviceState = _ServiceState();
  final _stdinBuffer = Uint8Buffer();
  StreamSubscription<List<int>>? _stdintSubscription;

  Service._() {
    dbg("create service");
  }

  factory Service.getInstanse() {
    _instanse ??= Service._();

    return _instanse!;
  }

  Rpc get rpc => _rpc;
  Controller get controller => _controller;
  Logger get logger => _logger;

  Future<void> load<T extends Object>(
      T Function(Map<String, dynamic>) createConfig) async {
    dbg("start service.load()");
    if (_serviceState.loaded) {
      throw Exception("the service is already loaded");
    }

    _serviceState.loaded = true;

    _stdintSubscription = stdin.listen((e) {
      dbg({'stdin listen': e});
      _stdinBuffer.addAll(e);
    });

    var buf = await _stdinRead(1);

    if (!buf.first.toServicePayloadKind().isInitial()) {
      throw Exception("invalid payload");
    }

    buf = await _stdinRead(4);
    final dataLen = buf.buffer.asUint32List().first;

    buf = await _stdinRead(dataLen);
    final Map<String, dynamic> inital = deserialize(buf);
    dbg({'inital': inital});
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
      dbg("stdin on done");
      _stdintSubscription?.cancel();
      await markTerminating();
      await _rpc.bus.disconnect();
    });

    _stdintSubscription?.onError((e) async {
      dbg("stdin on error");
      await _logger.error(e);
      _stdintSubscription?.cancel();
      await markTerminating();
      await _rpc.bus.disconnect();
    });
    Future.microtask(() => _handleStdin());
  }

  Future<void> waitCore() async {
    dbg("wait comlite");
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
    dbg("markTerminating()");
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

  Future<void> init(ServiceInfo info) async {
    dbg("init");
    
    if (!_serviceState.loaded) {
      throw Exception("first you need to run Service.load()");
    }

    //TODO dropPrivileges
    final bus = await _initBus();
    _logger = Logger(bus, _initPaload.core.logLevel.toLogLevel());
    _controller = Controller(bus);
    _serviceInfo = info;
    _rpc = Rpc(bus, onCall: _handleRpcCall, onFrane: _onFrameHandler);

    _registerSignals();
    await _markReady();

    Timer(Duration.zero, () async {
      while (_serviceState.active) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      await markTerminating();
    });
  }

  Future<void> subscribeOIDs(
      Iterable<(Oid, SubscriptionHandler)> items, EventKind kind) async {
    final sfx = kind.toEapiTopic();

    for (var (oid, fn) in items) {
      _subscriptionHandlers[oid.asPath()] = fn;
    }

    final topics = items.map((e) => sfx.resolve(e.$1.asPath())).toList();
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
    ProcessSignal.sigint.watch().listen((_) {
      _serviceState.active = false;
      dbg("signal: sigint");
    });
    ProcessSignal.sigterm.watch().listen((_) {
      _serviceState.active = false;
      dbg("signal: sigterm");
    });
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
      dbg({'_handleStdin': buf});
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
    dbg("rpc call");
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
      dbg(["_rpcCallWrapper", {'RpcEventKind': e.kind.value, "payload": e.payload, "method":  e.method}]);
      final ServiceMethod method =
          _serviceInfo.methods.firstWhere((i) => i.name == methodName);

      final params = deserialize(e.payload) as Map<String, dynamic>?;
      if (params == null) {
        return await method.fn({});
      }
      final prepParams = <String, dynamic>{};
      final reqParam = method.getRequared();
      final optParam =
          method.getOptional().where((e) => params.keys.contains(e));
      for (var pName in [...reqParam, ...optParam]) {
        prepParams[pName] = params[pName];
      }

      return await method.fn(prepParams);
    } on StateError {
      noRpcMethod(methodName);
      return null;
    }
  }

  FutureOr<void> _onFrameHandler(Frame f) async {
    dbg(["_rpcCallWrapper", {'topic': f.topic, "payload": f.payload, "sender":  f.sender}]);
    if (f.topic == null) {
      throw EvaError(EvaErrorKind.busData, "Frame topic is null");
    }

    final payload = ItemState.fromMap(f.topic!, deserialize(f.payload));

    if (_subscriptionHandlers[f.topic] != null) {
      return await _subscriptionHandlers[f.topic]!(
          payload, f.topic!, f.primarySender!);
    }

    final regexTopics = _subscriptionHandlers.keys
        .where((e) => e.endsWith("#") || e.contains("+"))
        .map((e) => (
              e.endsWith("#")
                  ? e.replaceFirst('#', ".*")
                  : e.replaceAll('+', '.+'),
              e
            ))
        .where((e) => RegExp(e.$1).hasMatch(f.topic!))
        .map((e) => e.$2);

    for (var topic in regexTopics) {
      _subscriptionHandlers[topic]!(payload, topic, f.primarySender!);
    }
  }
}
