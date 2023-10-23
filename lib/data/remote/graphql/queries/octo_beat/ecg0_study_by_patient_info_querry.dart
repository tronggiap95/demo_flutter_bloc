const String ecg0studyByPatientInfoQuerry = r'''
query ECG0studyByPatientInfo($filter: ECG0StudyByPatientInfoFilter!) {
  ECG0studyByPatientInfo(filter: $filter) {
    isSuccess
    message
    studyStatus
    study {
      id
      friendlyId
      deviceId
      status
      start
      stop
      lastLeadDisconnectedAt
      deviceType
      device {
        lastSync {
          time
        }
      }
      artifact {
        shouldBeResolved
        lastIssueFound
      }
    }
  }
}
''';
