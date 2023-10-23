import 'package:octo_beat_plugin/model/octo_beat_study_status_enum.dart';

class OctoBeatDevice {
  final bool isConnected;
  final String name;
  final String address;
  final bool batLow;
  final int batTime;
  final int batLevel;
  final bool isCharging;
  final OctoBeatStudyStatus? studyStatus;
  final bool isLeadConnected;
  final bool isServerConnected;

  OctoBeatDevice({
    required this.isConnected,
    required this.name,
    required this.address,
    required this.batLow,
    required this.isCharging,
    required this.batTime,
    required this.batLevel,
    required this.isServerConnected,
    required this.studyStatus,
    required this.isLeadConnected,
  });

  static OctoBeatDevice? fromMap(dynamic map) {
    if (map == null) {
      return null;
    }

    return OctoBeatDevice(
      isConnected: map['isConnected'] ?? false,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      batLow: map['batLow'] ?? false,
      isCharging: map['isCharging'] ?? false,
      batTime: map['batTime']?.toInt() ?? 0,
      batLevel: map['batLevel']?.toInt() ?? 0,
      isServerConnected: map['isServerConnected'] ?? false,
      studyStatus: OctoBeatStudyStatus.from(map['studyStatus'] ?? ''),
      isLeadConnected: map['isLeadConnected'] ?? false,
    );
  }

  @override
  String toString() {
    return 'OctoBeatDevice(isConnected: $isConnected, name: $name, address: $address, batLow: $batLow, batTime: $batTime, batLevel: $batLevel, isCharging: $isCharging, isLeadConnected: $isLeadConnected, isServerConnected: $isServerConnected, studyStatus: $studyStatus)';
  }
}
