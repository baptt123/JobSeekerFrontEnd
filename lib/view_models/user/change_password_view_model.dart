import 'package:flutter/material.dart';

import '../../dto/change_password_dto.dart';
import '../../services/change_password_service.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  final ChangePasswordService _authService = ChangePasswordService();

  final formKey = GlobalKey<FormState>();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> updatePassword(BuildContext context) async {
    // 1. Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    _setLoading(true);

    try {
      // 2. Create DTO
      final dto = ChangePasswordDto(
        oldPassword: oldPasswordController.text,
        newPassword: newPasswordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      // 3. Call service
      final successMessage = await _authService.updatePassword(dto);

      // 4. Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.green,
        ),
      );
      // Optional: Tự động quay lại màn hình trước đó sau khi thành công
      if (context.mounted) {
        Navigator.of(context).pop();
      }

    } catch (e) {
      // 5. Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _setLoading(false);
    }
  }

  // Dọn dẹp controller khi không dùng nữa
  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}