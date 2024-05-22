* This is a SDK for the https://github.com/eva-ics/eva4
* pub dev: https://pub.dev/packages/eva_sdk
<?code-excerpt "readme_excerpts.dart (Write)"?>
```dart
import 'package:eva_sdk/eva_sdk.dart';
import 'package:eva_sdk/src/debug_log.dart';

void main(List<String> args) async {
  bool isProd = !args.contains('--debug');
  // isProd = false;
  print(args);

  if (isProd) {
    dbgInit('/home/ut/log');
    await svc().load();
  } else {
    dbgInit('console');
    await svc().debugLoad('/home/andrei/documents/my/eva_sdk/bin/config.yaml');
  }

  await svc().init(ServiceInfo('losev', '0.0.0'));
  await svc().subscribeOIDs([(Oid('sensor:test1/sens1'), (x, y, z) => dbg([x.to<int>().toMap(), y, z]))], EventKind.any);
  await svc().subscribeRaw([('SVC/#', (a) => print([deserialize(a.payload), a.primarySender, a.topic]))]);
}
```
