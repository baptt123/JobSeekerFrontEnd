// lib/view_models/user/conversation_list_view_model.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/conversation-user-entity.dart';
import '../../services/conversation_service.dart';

// Định nghĩa các trạng thái của màn hình
enum ConversationState { loading, unauthorized, empty, success, error }

class ConversationListViewModel extends ChangeNotifier {
  final ConversationService _service = ConversationService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<ConversationUserEntity> _users = [];
  List<ConversationUserEntity> get users => _users;

  ConversationState _state = ConversationState.loading;
  ConversationState get state => _state;

  String _error = '';
  String get error => _error;

  ConversationListViewModel() {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    _state = ConversationState.loading;
    notifyListeners();

    try {
      // 1. Kiểm tra Token (Đăng nhập chưa?)
      final token = await _storage.read(key: 'accessToken');

      if (token == null) {
        // Chưa đăng nhập -> Chuyển trạng thái unauthorized
        _state = ConversationState.unauthorized;
        notifyListeners();
        return;
      }

      // 2. Đã đăng nhập -> Gọi API
      _users = await _service.getConversationList();

      // 3. Kiểm tra kết quả
      if (_users.isEmpty) {
        _state = ConversationState.empty;
      } else {
        _state = ConversationState.success;
      }
    } catch (e) {
      // Nếu lỗi do Token hết hạn hoặc lỗi mạng
      if (e.toString().contains('401')) {
        _state = ConversationState.unauthorized;
      } else {
        _error = e.toString();
        _state = ConversationState.error;
      }
    } finally {
      notifyListeners();
    }
  }
}