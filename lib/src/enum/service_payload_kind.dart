enum ServicePayloadKind {
  initial,
  ping;

  int code() => switch (this) {
        ServicePayloadKind.initial => 1,
        ServicePayloadKind.ping => 0,
      };

  bool isInitial() => this == ServicePayloadKind.initial;

  bool isPing() => this == ServicePayloadKind.ping;
}

extension ToServicePayloadKind on int {
  ServicePayloadKind toServicePayloadKind() => switch (this) {
        0 => ServicePayloadKind.ping,
        1 => ServicePayloadKind.initial,
        _ => throw Exception("$this in not ServicePayloadKind"),
      };
}
