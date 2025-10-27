import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../view_models/user/zoom_view_model.dart';
import 'zoom_view_meeting_screen.dart';

class ZoomCreateMeetingScreen extends StatefulWidget {
  const ZoomCreateMeetingScreen({super.key});

  @override
  State<ZoomCreateMeetingScreen> createState() => _ZoomCreateMeetingScreenState();
}

class _ZoomCreateMeetingScreenState extends State<ZoomCreateMeetingScreen> {
  final TextEditingController _topicController = TextEditingController();

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();
  }

  @override
  Widget build(BuildContext context) {
    // Lấy ZoomViewModel từ Provider
    final zoomVM = context.watch<ZoomViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tạo cuộc họp Zoom')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'Chủ đề cuộc họp',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            zoomVM.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () async {
                final topic = _topicController.text.trim();
                if (topic.isEmpty) return;

                // Request quyền trước khi tạo meeting
                await _requestPermissions();

                await zoomVM.createMeeting(topic);

                if (zoomVM.meeting != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ZoomWebViewScreen(
                        meetingUrl: zoomVM.meeting!.joinUrl,
                      ),
                    ),
                  );
                } else if (zoomVM.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(zoomVM.errorMessage!)),
                  );
                }
              },
              child: const Text('Tạo và Tham gia Meeting'),
            ),
          ],
        ),
      ),
    );
  }
}
