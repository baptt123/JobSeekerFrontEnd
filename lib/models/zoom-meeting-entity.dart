class ZoomMeetingEntity {
  final String meetingId;
  final String joinUrl;
  final String startUrl;

  ZoomMeetingEntity({
    required this.meetingId,
    required this.joinUrl,
    required this.startUrl,
  });

  factory ZoomMeetingEntity.fromJson(Map<String, dynamic> json) => ZoomMeetingEntity(
    meetingId: json['meetingId'].toString(),
    joinUrl: json['joinUrl'],
    startUrl: json['startUrl'],
  );
}
