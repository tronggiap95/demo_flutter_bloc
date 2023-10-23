class OctoTask {
  final String event;
  final dynamic data;

  OctoTask({
    required this.event,
    required this.data,
  });

  static OctoTask fromMap(dynamic map) {
    return OctoTask(
      event: map['event'] ?? '',
      data: map['body'],
    );
  }
}
