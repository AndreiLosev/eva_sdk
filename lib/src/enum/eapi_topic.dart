enum EapiTopic {
  rawStateTopic,
  localStateTopic,
  remoteStateTopic,
  remoteArchiveStateTopic,
  anyStateTopic,
  replicationStateTopic,
  replicationInventoryTopic,
  replicationNodeStateTopic,
  logInputTopic,
  logEventTopic,
  logCallTraceTopic,
  serviceStatusTopic,
  aaaAclTopic,
  aaaKeyTopic,
  aaaUserTopic,
  actionStatus;

  String resolve([String topic = ""]) {
    return switch (this) {
      rawStateTopic => 'RAW/$topic',
      localStateTopic => 'ST/LOC/$topic',
      remoteStateTopic => 'ST/REM/$topic',
      remoteArchiveStateTopic => 'ST/RAR/$topic',
      anyStateTopic => 'ST/+/$topic',
      replicationStateTopic => 'RPL/ST/$topic',
      replicationInventoryTopic => 'RPL/INVENTORY/$topic',
      replicationNodeStateTopic => 'RPL/NODE/$topic',
      logInputTopic => 'LOG/IN/$topic',
      logEventTopic => 'LOG/EV/$topic',
      logCallTraceTopic => 'LOG/TR/$topic',
      serviceStatusTopic => 'SVC/ST/$topic',
      aaaAclTopic => 'AAA/ACL/$topic',
      aaaKeyTopic => 'AAA/KEY/$topic',
      aaaUserTopic => 'AAA/USER/$topic',
      actionStatus => 'ACT/$topic',
    };
  }
}
