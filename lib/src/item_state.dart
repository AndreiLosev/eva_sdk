import 'package:eva_sdk/eva_sdk.dart';
import 'package:eva_sdk/src/enum/eva_error_kind.dart';

class ItemState {
  final Oid oid;
  final int status;
  final dynamic value;
  final DateTime t;
  final (int, int) ieid;

  ItemState(this.oid, this.status, this.value, this.t, this.ieid);

  factory ItemState.fromMap(String topic, Map<String, dynamic> map) {
    final hasMatches = EventKind.values
        .where((e) => e != EventKind.any)
        .map((e) => e.toEapiTopic())
        .firstWhere((e) => e.hasMatch(topic))
        .topic(topic);

    final oid = Oid(hasMatches, true);

    final microseconds = (map['t'] * 1000000) as num;
    final t = DateTime.fromMicrosecondsSinceEpoch(microseconds.toInt());
    final ieid = (map['ieid'][0] as int, map['ieid'][1] as int);

    return ItemState(oid, map['status'], map['value'], t, ieid);
  }

  void _checkValueType<T>(T _) {
    if (value is! T) {
      throw EvaError(EvaErrorKind.busData,
          "value type ${value.runtimeType}, but value must be $T");
    }
  }

  ItemStateBool asBool() => ItemStateBool(oid, status, value, t, ieid);

  ItemStateInt asInt() => ItemStateInt(oid, status, value, t, ieid);

  ItemStateDouble asDouble() => ItemStateDouble(oid, status, value, t, ieid);

  ItemStateString asString() => ItemStateString(oid, status, value, t, ieid);
}

class ItemStateBool extends ItemState {
  ItemStateBool(super.oid, super.status, super.value, super.t, super.ieid) {
    _checkValueType(true);
  }

  @override
  bool get value => super.value as bool;
}

class ItemStateInt extends ItemState {
  ItemStateInt(super.oid, super.status, super.value, super.t, super.ieid) {
    _checkValueType(1);
  }

  @override
  int get value => super.value as int;
}

class ItemStateDouble extends ItemState {
  ItemStateDouble(super.oid, super.status, super.value, super.t, super.ieid) {
    _checkValueType(1.1);
  }

  @override
  double get value => super.value as double;
}

class ItemStateString extends ItemState {
  ItemStateString(super.oid, super.status, super.value, super.t, super.ieid) {
    _checkValueType("w");
  }

  @override
  String get value => super.value as String;
}
