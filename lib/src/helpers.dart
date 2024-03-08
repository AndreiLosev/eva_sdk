import 'dart:typed_data';

import 'package:msgpack_dart/msgpack_dart.dart';

extension MessagePackSerialize on Serializer {
  Uint8List puck(dynamic v) {
    encode(v);
    return takeBytes();
  }
}
