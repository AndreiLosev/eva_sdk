import 'dart:io';

class DebugLog {
  static DebugLog? _instanse;

  final String? _path;

  DebugLog._(this._path);

  static DebugLog? getInstanse([String? path]) {
    if (_instanse == null && path == null) {
      return null;
    }
    _instanse ??= DebugLog._(path!);

    return _instanse!;
  }

  void log(Object mess) {
    if (_path == null) {
      return;
    }

    if (_path == 'console') {
      print(mess);
      return;
    }

    File(_path).writeAsStringSync(
      "${mess.toString()} ${Platform.lineTerminator}",
      mode: FileMode.append,
    );
  }
}

void dbgInit(String path) {
  DebugLog.getInstanse(path);
}

void dbg(Object mess) {
  DebugLog.getInstanse()?.log(mess);
}
