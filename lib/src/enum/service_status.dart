enum ServiceStatus {
  ready,
  terminating;

  @override
  String toString() => switch (this) {
        ServiceStatus.ready => 'ready',
        ServiceStatus.terminating => 'terminating',
      };
}
