class ZoomMeetingDto {
  final String meetingId;
  final String joinUrl;
  final String startUrl;

  ZoomMeetingDto({
    required this.meetingId,
    required this.joinUrl,
    required this.startUrl,
  });

  factory ZoomMeetingDto.fromJson(Map<String, dynamic> json) {
    return ZoomMeetingDto(
      meetingId: json['meetingId'].toString(),
      joinUrl: json['joinUrl'] ?? '',
      startUrl: json['startUrl'] ?? '',
    );
  }
}
