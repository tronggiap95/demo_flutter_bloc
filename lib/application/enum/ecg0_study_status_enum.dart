import 'package:json_annotation/json_annotation.dart';

enum ECG0StudyStatus {
  @JsonValue('Draft')
  draft,
  @JsonValue('Starting')
  starting,
  @JsonValue('Aborted')
  aborted,
  @JsonValue('Ongoing')
  onGoing,
  @JsonValue('Completed')
  completed,
  @JsonValue('Done')
  done;

  static ECG0StudyStatus? from(String? value) {
    switch (value) {
      case 'Draft':
        return ECG0StudyStatus.draft;
      case 'Starting':
        return ECG0StudyStatus.starting;
      case 'Aborted':
        return ECG0StudyStatus.aborted;
      case 'Ongoing':
        return ECG0StudyStatus.onGoing;
      case 'Completed':
        return ECG0StudyStatus.completed;
      case 'Done':
        return ECG0StudyStatus.done;
    }
    return null;
  }
}
