import 'package:json_annotation/json_annotation.dart';

enum OctoStudyStatus {
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

  static OctoStudyStatus? from(String? value) {
    switch (value) {
      case 'Draft':
        return OctoStudyStatus.draft;
      case 'Starting':
        return OctoStudyStatus.starting;
      case 'Aborted':
        return OctoStudyStatus.aborted;
      case 'Ongoing':
        return OctoStudyStatus.onGoing;
      case 'Completed':
        return OctoStudyStatus.completed;
      case 'Done':
        return OctoStudyStatus.done;
    }
    return null;
  }
}
