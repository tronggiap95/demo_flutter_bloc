enum OctobeatStudyStatus {
  ready,
  setting,
  studyProgress,
  studyPaused,
  studyCompleted,
  studyUploaded,
  studyUploading,
  studyCreated,
  studyAborted;

  static OctobeatStudyStatus? from(String status) {
    switch (status) {
      case 'Ready for new study':
        return OctobeatStudyStatus.ready;
      case 'Setting up':
        return OctobeatStudyStatus.setting;
      case 'Study Paused':
        return OctobeatStudyStatus.studyPaused;
      case 'Study Completed':
        return OctobeatStudyStatus.studyCompleted;
      case 'Study Uploaded':
        return OctobeatStudyStatus.studyUploaded;
      case 'Uploading study data':
        return OctobeatStudyStatus.studyUploading;
      case 'Study created':
        return OctobeatStudyStatus.studyCreated;
      case 'Aborted':
        return OctobeatStudyStatus.studyAborted;
      default:
        if (status.contains("Study is in progress")) {
          return OctobeatStudyStatus.studyProgress;
        }
        return null;
    }
  }

  String get getValue {
    switch (this) {
      case OctobeatStudyStatus.ready:
        return 'Ready for new study';
      case OctobeatStudyStatus.setting:
        return 'Setting up';
      case OctobeatStudyStatus.studyProgress:
        return 'Study is in progress';
      case OctobeatStudyStatus.studyPaused:
        return 'Study Paused';
      case OctobeatStudyStatus.studyCompleted:
        return 'Study Completed';
      case OctobeatStudyStatus.studyUploaded:
        return 'Study Uploaded';
      case OctobeatStudyStatus.studyUploading:
        return 'Uploading study data';
      case OctobeatStudyStatus.studyCreated:
        return 'Study created';
      case OctobeatStudyStatus.studyAborted:
        return 'Aborted';
    }
  }
}
