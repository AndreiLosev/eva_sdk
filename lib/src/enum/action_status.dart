enum ActionStatus {
  created,
  accepted,
  pending,
  running,
  completed,
  failed,
  canceled,
  terminated;

  int code() => switch (this) {
        ActionStatus.created => 0,
        ActionStatus.accepted => 1,
        ActionStatus.pending => 2,
        ActionStatus.running => 8,
        ActionStatus.completed => 15,
        ActionStatus.failed => 128,
        ActionStatus.canceled => 129,
        ActionStatus.terminated => 130,
      };
}

extension ToActionsStatus on int {
  ActionStatus toActionsStatus() => switch (this) {
        0 => ActionStatus.created,
        1 => ActionStatus.accepted,
        2 => ActionStatus.pending,
        8 => ActionStatus.running,
        15 => ActionStatus.completed,
        128 => ActionStatus.failed,
        129 => ActionStatus.canceled,
        130 => ActionStatus.terminated,
        _ => throw Exception("$this in not ActionStatus"),
      };
}
