import 'package:eva_sdk/src/enums.dart';

class Oid {
  late final ItemKind kind;
  late final String fullId;

  Oid(String id, [bool fromPath = false]) {
    final pos = id.indexOf(fromPath ? "/" : ":");
    if (pos == -1) {
      throw Exception("invalid OID: $id");
    }
  
    kind = id.substring(0, pos).toItemKind();
    fullId = id.substring(pos + 1);
  }

  String asString() => "$kind:fullId";

  String asPath() => "$kind/fullId";

  bool equal(Oid other) =>
      kind == other.kind && fullId == other.fullId;
}
