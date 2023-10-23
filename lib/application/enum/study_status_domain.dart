import 'package:flutter/material.dart';
import 'package:octo360/application/enum/octo_study_status_enum.dart';
import 'package:octo360/src/colors/colors_app.dart';

enum StudyStatusDomain {
  none,
  paused,
  inProgress,
  completed,
  draft;

  static StudyStatusDomain from(String? lastStatus, OctoStudyStatus? status) {
    if (lastStatus == 'Paused') {
      return StudyStatusDomain.paused;
    }

    if (status == null) {
      return StudyStatusDomain.none;
    }

    switch (status) {
      case OctoStudyStatus.completed:
      case OctoStudyStatus.done:
        return StudyStatusDomain.completed;
      case OctoStudyStatus.draft:
        return StudyStatusDomain.draft;
      default:
        return StudyStatusDomain.inProgress;
    }
  }

  Color get textColor {
    switch (this) {
      case StudyStatusDomain.paused:
        return ColorsApp.greenLighter;
      default:
        return ColorsApp.coalDarkest;
    }
  }
}
