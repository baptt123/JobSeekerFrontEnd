// class CallHistoryEntity {
//   final int id;
//   final int hostId;
//   final int guestId;
//   final String roomId;
//   final String jitsiUrl;
//   final DateTime startTime;
//   final DateTime? endTime;
//
//   CallHistoryEntity({
//     required this.id,
//     required this.hostId,
//     required this.guestId,
//     required this.roomId,
//     required this.jitsiUrl,
//     required this.startTime,
//     this.endTime,
//   });
//
//   factory CallHistoryEntity.fromJson(Map<String, dynamic> json) {
//     return CallHistoryEntity(
//       id: json['id'],
//       hostId: json['host_id'],
//       guestId: json['guest_id'],
//       roomId: json['room_id'],
//       jitsiUrl: json['jitsi_url'],
//       startTime: DateTime.parse(json['start_time']),
//       endTime:
//       json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
//     );
//   }
// }
