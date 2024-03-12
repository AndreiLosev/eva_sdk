import 'dart:io';

class DebugLog {
  static DebugLog? _instanse;

  final String? _path;

  DebugLog._(this._path);

  factory DebugLog.getInstanse([String? path]) {
    _instanse ??= DebugLog._(path!);

    return _instanse!;
  }

  void log(Object mess) {
    if (_path == null) {
      return;
    }
    File(_path).writeAsStringSync(mess.toString(), mode: FileMode.append);
  }
}

void dbgInit(String path) {
  DebugLog.getInstanse(path);
}

void dbg(Object mess) {
  try {
    DebugLog.getInstanse().log("${mess.toString()} ${Platform.lineTerminator}");
  } catch (_) {}
}
