import 'package:octo_beat_plugin/connection/octo_connection_event.dart';
import 'package:octo_beat_plugin/connection/octo_scan_result.dart';

class OctoConnectionData {
  final OctoConnectionEvent? event;
  final dynamic data;

  OctoConnectionData({
    required this.event,
    required this.data,
  });

  List<OctoScanResult> toScanResults() {
    return (data['devices'] as List)
        .map((e) => OctoScanResult.fromMap(e))
        .toList();
  }

  OctoScanResult toSuccessResult() {
    return OctoScanResult.fromMap(data);
  }
}
