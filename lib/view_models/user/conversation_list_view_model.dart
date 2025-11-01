// view_models/chat/conversation_list_view_model.dart (TẠO FILE MỚI)

import 'package:flutter/material.dart';
import '../../models/conversation-user-entity.dart';
import '../../services/conversation_service.dart';

class ConversationListViewModel extends ChangeNotifier {
  final ConversationService _service = ConversationService();

  List<ConversationUserEntity> _users = [];
  List<ConversationUserEntity> get users => _users;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _error = '';
  String get error => _error;

  ConversationListViewModel() {
    fetchUsers(); // Tự động gọi API khi khởi tạo
  }

  Future<void> fetchUsers() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _users = await _service.getConversationList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}