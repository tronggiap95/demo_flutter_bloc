// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:octo_beat_plugin/connection/octo_beat_connection_event.dart';
import 'package:octo_beat_plugin/connection/octo_beat_scan_result.dart';

class OctoBeatConnectionData {
  final OctoBeatConnectionEvent? event;
  final dynamic data;

  OctoBeatConnectionData({
    required this.event,
    required this.data,
  });

  List<OctoBeatScanResult> toScanResults() {
    return (data['devices'] as List)
        .map((e) => OctoBeatScanResult.fromMap(e))
        .toList();
  }

  OctoBeatScanResult toSuccessResult() {
    return OctoBeatScanResult.fromMap(data);
  }

  @override
  String toString() => 'OctoBeatConnectionData(event: $event, data: $data)';
}
