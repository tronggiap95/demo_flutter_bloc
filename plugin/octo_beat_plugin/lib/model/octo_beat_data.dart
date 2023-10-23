import 'package:octo_beat_plugin/model/octo_beat_device.dart';
import 'package:octo_beat_plugin/model/octo_beat_event.dart';

class OctoBeatData {
  final OctoBeatEvent event;
  final dynamic data;

  OctoBeatData({
    required this.event,
    required this.data,
  });

  static OctoBeatData fromMap(dynamic map) {
    return OctoBeatData(
      event: OctoBeatEvent.from(map['event']),
      data: map['body'],
    );
  }

  OctoBeatDevice? toOctoBeatDevice() {
    return OctoBeatDevice.fromMap(data);
  }

  int? toMctEventTime() {
    return data?['mctEventTime'] ?? 0;
  }
}
