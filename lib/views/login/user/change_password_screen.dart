import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/view_models/user/change_password_view_model.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<ChangePasswordViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Đổi mật khẩu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _oldPassController,
                decoration: const InputDecoration(labelText: 'Mật khẩu cũ', border: OutlineInputBorder()),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập mật khẩu cũ' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPassController,
                decoration: const InputDecoration(labelText: 'Mật khẩu mới', border: OutlineInputBorder()),
                obscureText: true,
                validator: (value) => (value!.length < 6) ? 'Mật khẩu phải hơn 6 ký tự' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPassController,
                decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu mới', border: OutlineInputBorder()),
                obscureText: true,
                validator: (value) {
                  if (value != _newPassController.text) return 'Mật khẩu không khớp';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: authViewModel.isLoading
                      ? null
                      : () async {
                    if (_formKey.currentState!.validate()) {
                      // Gọi hàm changePassword từ ViewModel (bạn cần implement hàm này trong AuthViewModel)
                      /* bool success = await authViewModel.changePassword(
                              _oldPassController.text,
                              _newPassController.text
                            );
                            if (success && context.mounted) Navigator.pop(context);
                            */
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chức năng đang được cập nhật trong ViewModel')),
                      );
                    }
                  },
                  child: authViewModel.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Cập nhật mật khẩu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}