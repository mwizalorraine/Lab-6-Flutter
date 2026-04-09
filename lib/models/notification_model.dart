class NotificationModel {
  final String title;
  final String body;
  final DateTime receivedAt;
  final Map<String, dynamic> data;
  final String source; // "foreground", "background", "terminated"

  NotificationModel({
    required this.title,
    required this.body,
    required this.receivedAt,
    this.data = const {},
    this.source = 'foreground',
  });

  @override
  String toString() => '$title: $body ($source)';
}
