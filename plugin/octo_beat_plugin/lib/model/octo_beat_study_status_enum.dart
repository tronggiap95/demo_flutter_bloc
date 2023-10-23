enum OctoBeatStudyStatus {
  draft,
  ready,
  setting,
  studyProgress,
  studyPaused,
  studyCompleted,
  studyUploaded,
  studyUploading,
  studyCreated,
  studyAborted,
  studyDone;

  static OctoBeatStudyStatus? fromECG0StudyStatus(
      {required String? studyStatus, required String? lastHistoryStudyStatus}) {
    switch (studyStatus) {
      case 'Draft':
        return OctoBeatStudyStatus.draft;
      case 'Starting':
        return OctoBeatStudyStatus.setting;
      case 'Ongoing':
        return OctoBeatStudyStatus.studyProgress;
      case 'Aborted':
        return OctoBeatStudyStatus.studyAborted;
      case 'Done':
        return OctoBeatStudyStatus.studyDone;
      default:
    }
    switch (lastHistoryStudyStatus) {
      case 'Paused':
        return OctoBeatStudyStatus.studyPaused;
      case 'Completed':
        return OctoBeatStudyStatus.studyCompleted;
      case 'Uploaded':
        return OctoBeatStudyStatus.studyUploaded;
      case 'Uploading':
        return OctoBeatStudyStatus.studyUploading;
      default:
        return null;
    }
  }

  static OctoBeatStudyStatus? from(String status) {
    switch (status) {
      case 'Draft':
        return OctoBeatStudyStatus.draft;
      case 'Ready for new study':
        return OctoBeatStudyStatus.ready;
      case 'Setting up':
        return OctoBeatStudyStatus.setting;
      case 'Study Paused':
        return OctoBeatStudyStatus.studyPaused;
      case 'Study Completed':
        return OctoBeatStudyStatus.studyCompleted;
      case 'Study Uploaded':
        return OctoBeatStudyStatus.studyUploaded;
      case 'Uploading study data':
        return OctoBeatStudyStatus.studyUploading;
      case 'Study created':
        return OctoBeatStudyStatus.studyCreated;
      case 'Aborted':
        return OctoBeatStudyStatus.studyAborted;
      default:
        if (status.contains("Study is in progress")) {
          return OctoBeatStudyStatus.studyProgress;
        }
        return null;
    }
  }

  String get getValue {
    switch (this) {
      case OctoBeatStudyStatus.draft:
        return 'Draft';
      case OctoBeatStudyStatus.ready:
        return 'Ready for new study';
      case OctoBeatStudyStatus.setting:
        return 'Setting up';
      case OctoBeatStudyStatus.studyProgress:
        return 'Study is in progress';
      case OctoBeatStudyStatus.studyPaused:
        return 'Study Paused';
      case OctoBeatStudyStatus.studyCompleted:
        return 'Study Completed';
      case OctoBeatStudyStatus.studyUploaded:
        return 'Study Uploaded';
      case OctoBeatStudyStatus.studyUploading:
        return 'Uploading study data';
      case OctoBeatStudyStatus.studyCreated:
        return 'Study created';
      case OctoBeatStudyStatus.studyAborted:
        return 'Aborted';
      case OctoBeatStudyStatus.studyDone:
        return 'Done';
    }
  }
}
