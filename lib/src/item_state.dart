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

  ItemStateTyped<T> to<T extends Object>() {
    if (value is! T) {
      throw EvaError(EvaErrorKind.busData,
          "value type ${value.runtimeType}, but expected $T");
    }

    return ItemStateTyped<T>(oid, status, value, t, ieid);
  }
}

class ItemStateTyped<T extends Object> extends ItemState {
  ItemStateTyped(super.oid, super.status, super.value, super.t, super.ieid);

  @override
  T get value {
    return super.value as T;
  }
}
