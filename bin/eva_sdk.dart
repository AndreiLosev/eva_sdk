
import 'package:busrt_client/busrt_client.dart';
import 'package:msgpack_dart/msgpack_dart.dart';

void main(List<String> arguments) async {
  final bus = Bus("worker.test1");
  await bus.connect("192.168.100.101:7777");

  final rpc = Rpc(bus, onFrane: (f) {
    print([f.topic, f.primarySender, deserialize(f.payload)]);
  });

  rpc.bus.subscribe(["ST/LOC/sensor/+/a_level"]);
}
