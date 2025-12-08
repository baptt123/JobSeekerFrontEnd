// lib/view_models/user/conversation_list_view_model.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/conversation-user-entity.dart';
import '../../services/conversation_service.dart';

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

  // ✅ 1. Thêm cờ kiểm tra trạng thái dispose
  bool _isDisposed = false;

  ConversationListViewModel() {
    fetchUsers();
  }

  // ✅ 2. Override hàm dispose để đánh dấu cờ
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> fetchUsers() async {
    // Nếu đã dispose thì không làm gì cả
    if (_isDisposed) return;

    _state = ConversationState.loading;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'accessToken');

      // Check lại lần nữa sau khi await
      if (_isDisposed) return;

      if (token == null) {
        _state = ConversationState.unauthorized;
        notifyListeners();
        return;
      }

      _users = await _service.getConversationList();

      // Check lại lần nữa sau khi await API
      if (_isDisposed) return;

      if (_users.isEmpty) {
        _state = ConversationState.empty;
      } else {
        _state = ConversationState.success;
      }
    } catch (e) {
      if (_isDisposed) return; // Check trước khi set state lỗi

      if (e.toString().contains('401')) {
        _state = ConversationState.unauthorized;
      } else {
        _error = e.toString();
        _state = ConversationState.error;
      }
    } finally {
      // ✅ 3. Chỉ notify nếu chưa dispose
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }
}