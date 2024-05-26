import 'dart:async';
import 'dart:collection';

import 'package:eva_sdk/eva_sdk.dart';

class ActionQueueItem {
  final Action uAction;
  final Completer<ActionStatus> completer;
  final FutureOr<void> Function() fn;

  ActionQueueItem(this.uAction, this.fn) : completer = Completer();
}

class ActionQueue {
  final _queue = Queue<ActionQueueItem>();
  bool _locker = false;
  bool _run = false;
  final int _limit;

  ActionQueue(this._limit);

  Completer<ActionStatus> add(Action uAction, FutureOr<void> Function() fn) {
    if (_queue.length >= _limit) {
      svc().logger.warn("ActionQueue reached the limit");
      throw Exception("ActionQueue reached the limit");
    }
    final item = ActionQueueItem(uAction, fn);
    _queue.add(item);
    svc().controller.eventPending(item.uAction);

    return item.completer;
  }

  void terminate(String uuid) {
    final item = _queue.firstWhere((e) => e.uAction.uuid == uuid);
    _queue.remove(item);
    svc().controller.eventTerminated(item.uAction);
    item.completer.complete(ActionStatus.terminated);
  }

  void kill(Oid oid) {
    final item =
        _queue.firstWhere((e) => e.uAction.oid.asString() == oid.asString());
    _queue.remove(item);
    svc().controller.eventCanceled(item.uAction);
    item.completer.complete(ActionStatus.canceled);
  }

  void stop() => _run = false;

  Future<void> run() async {
    _run = true;
    while (_run) {
      if (_locker) {
        await Future.delayed(const Duration(milliseconds: 10));
        continue;
      }

      try {
        _locker = true;
        final item = _queue.removeFirst();
        svc().controller.eventRunning(item.uAction);
        try {
          await item.fn();
          item.completer.complete(ActionStatus.completed);
          svc().controller.eventCompleted(item.uAction);
        } catch (e) {
          item.completer.complete(ActionStatus.failed);
          svc().controller.eventFailed(item.uAction,
              out: 'unit action', err: e, exitcode: 1);
        }
      } on StateError {
        await Future.delayed(const Duration(milliseconds: 10));
      } finally {
        _locker = false;
      }
    }
  }
}
