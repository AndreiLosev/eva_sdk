enum ItemKind {
  unit,
  sensor,
  lVar,
  lMacro,
  any;

  @override
  String toString() => switch (this) {
        ItemKind.unit => "unit",
        ItemKind.sensor => "sensor",
        ItemKind.lVar => "lvar",
        ItemKind.lMacro => "lmacro",
        ItemKind.any => "+",
      };
}

extension ToItemKind on String {
  ItemKind toItemKind() => switch (this) {
        "unit" => ItemKind.unit,
        "sensor" => ItemKind.sensor,
        "lvar" => ItemKind.lVar,
        "imacro" => ItemKind.lMacro,
        "+" => ItemKind.any,
        _ => throw Exception("invalid item kind: $this"),
      };
}
