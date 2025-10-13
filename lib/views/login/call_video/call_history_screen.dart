// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import '../../../view_models/user/call_view_model.dart';
//
// class CallHistoryScreen extends StatefulWidget {
//   final int userId;
//   const CallHistoryScreen({super.key, required this.userId});
//
//   @override
//   State<CallHistoryScreen> createState() => _CallHistoryScreenState();
// }
//
// class _CallHistoryScreenState extends State<CallHistoryScreen> {
//   final _dateFormatter = DateFormat('HH:mm:ss dd/MM/yyyy');
//
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() =>
//         context.read<CallViewModel>().loadHistory(widget.userId));
//   }
//
//   String _formatDuration(DateTime start, DateTime? end) {
//     if (end == null) return '---';
//     final duration = end.difference(start);
//     final hours = duration.inHours;
//     final minutes = duration.inMinutes.remainder(60);
//     final seconds = duration.inSeconds.remainder(60);
//     if (hours > 0) return '${hours}h ${minutes}m ${seconds}s';
//     if (minutes > 0) return '${minutes}m ${seconds}s';
//     return '${seconds}s';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final vm = context.watch<CallViewModel>();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('📞 Lịch sử cuộc gọi'),
//         centerTitle: true,
//       ),
//       body: vm.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : vm.history.isEmpty
//           ? const Center(
//         child: Text(
//           'Chưa có lịch sử cuộc gọi',
//           style: TextStyle(fontSize: 16, color: Colors.grey),
//         ),
//       )
//           : ListView.separated(
//         padding: const EdgeInsets.all(8),
//         itemCount: vm.history.length,
//         separatorBuilder: (_, __) => const Divider(height: 1),
//         itemBuilder: (context, index) {
//           final call = vm.history[index];
//           final start = _dateFormatter.format(call.startTime);
//           final end = call.endTime != null
//               ? _dateFormatter.format(call.endTime!)
//               : '---';
//           final duration =
//           _formatDuration(call.startTime, call.endTime);
//
//           return ListTile(
//             leading: const Icon(Icons.video_call, color: Colors.blue),
//             title: Text(
//               'Phòng: ${call.roomId}',
//               style: const TextStyle(
//                   fontWeight: FontWeight.w600, fontSize: 16),
//             ),
//             subtitle: Padding(
//               padding: const EdgeInsets.only(top: 4.0),
//               child: Text(
//                 '🕒 Bắt đầu: $start\n'
//                     '🏁 Kết thúc: $end\n'
//                     '⏱ Thời lượng: $duration',
//                 style: const TextStyle(fontSize: 13),
//               ),
//             ),
//             trailing: Text(
//               '#${call.id}',
//               style:
//               const TextStyle(color: Colors.grey, fontSize: 12),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
