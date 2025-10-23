import 'package:flutter/foundation.dart';
import '../../models/user-entity.dart';
import '../../services/chat_service.dart';

class LoginChatViewModel extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  bool isLoading = false;
  UserEntity? currentUser;
  String? errorMessage;
  bool get isLoggedIn => currentUser != null;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<UserEntity> login(String fullName) async {
    try {
      setLoading(true);
      final user = await _chatService.login(fullName);
      errorMessage = null;
      return user;
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    } finally {
      setLoading(false);
    }
  }
}
