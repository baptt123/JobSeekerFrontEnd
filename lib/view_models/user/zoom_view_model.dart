import 'package:flutter/material.dart';

import '../../dto/zoom_meeting_dto.dart';
import '../../services/zoom_service.dart';

class ZoomViewModel extends ChangeNotifier {
  final ZoomService _zoomService = ZoomService();

  ZoomMeetingDto? _meeting;
  bool _isLoading = false;
  String? _errorMessage;

  ZoomMeetingDto? get meeting => _meeting;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> createMeeting(String topic) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _meeting = await _zoomService.createMeeting(topic);
    } catch (e) {
      _errorMessage = "Không thể tạo cuộc họp Zoom. Vui lòng thử lại.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
