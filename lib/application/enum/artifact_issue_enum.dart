
import 'package:json_annotation/json_annotation.dart';
import 'package:octo360/src/strings/string_manager.dart';

enum ArtifactIssueEnum {
  @JsonValue('Artifact')
  artifact, // Artifacts in all channels
  @JsonValue('LeadOff')
  leadOff, // Lead off on diagnosis channel
  @JsonValue('LeadOff2')
  leadOff2, // More than one lead disconnected
  @JsonValue('LeadOff3')
  leadOff3, // All leads or ECG cable disconnected
  @JsonValue('LeadOffLL')
  leadOffLL, // Lead LL disconnected
  @JsonValue('LeadOffLA')
  leadOffLA, // Lead LA disconnected
  @JsonValue('LeadOffRA')
  leadOffRA, // Lead RA disconnected
  @JsonValue('MissingStrips')
  missingStrips,
  @JsonValue('Offline')
  offline, // The device has been offline for more than 12 hours
  @JsonValue('Paused')
  paused; // The study has been paused for more than 8 hours

  String get getDisplayValue {
    switch (this) {
      case ArtifactIssueEnum.artifact:
      case ArtifactIssueEnum.leadOff:
      case ArtifactIssueEnum.leadOff2:
      case ArtifactIssueEnum.leadOff3:
      case ArtifactIssueEnum.leadOffLL:
      case ArtifactIssueEnum.leadOffLA:
      case ArtifactIssueEnum.leadOffRA:
        return StringsApp.commonIssuesLead;
      case ArtifactIssueEnum.missingStrips:
        return '';
      case ArtifactIssueEnum.offline:
        return StringsApp.commonIssuesServer;
      case ArtifactIssueEnum.paused:
        return StringsApp.commonIssuesStudy;
    }
  }

  static ArtifactIssueEnum? from(String? value) {
    switch (value) {
      case 'Artifact':
        return ArtifactIssueEnum.artifact;
      case 'LeadOff':
        return ArtifactIssueEnum.leadOff;
      case 'LeadOff2':
        return ArtifactIssueEnum.leadOff2;
      case 'LeadOff3':
        return ArtifactIssueEnum.leadOff3;
      case 'LeadOffLL':
        return ArtifactIssueEnum.leadOffLL;
      case 'LeadOffLA':
        return ArtifactIssueEnum.leadOffLA;
      case 'LeadOffRA':
        return ArtifactIssueEnum.leadOffRA;
      case 'Offline':
        return ArtifactIssueEnum.offline;
      case 'Paused':
        return ArtifactIssueEnum.paused;
    }
    return null;
  }
}
