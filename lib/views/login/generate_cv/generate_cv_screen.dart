import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../dto/create_user_cv_dto.dart';
import '../../../services/generate_cv_service.dart';
import '../../../view_models/user/generate_cv_view_model.dart';


class GenerateCvPage extends StatelessWidget {
  final String baseUrl; // truyền vào khi khởi tạo

  const GenerateCvPage({Key? key, required this.baseUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GenerateCvViewModel>(
      create: (_) => GenerateCvViewModel(apiService: GenerativeCVService()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Tạo CV bằng Gemini')),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: _GenerateCvForm(),
        ),
      ),
    );
  }
}

class _GenerateCvForm extends StatefulWidget {
  const _GenerateCvForm({Key? key}) : super(key: key);

  @override
  State<_GenerateCvForm> createState() => _GenerateCvFormState();
}

class _GenerateCvFormState extends State<_GenerateCvForm> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _titleController = TextEditingController(text: 'CV mới');
  final TextEditingController _keywordsController = TextEditingController(); // comma separated
  final TextEditingController _userIdController = TextEditingController(text: '1');

  @override
  void dispose() {
    _promptController.dispose();
    _titleController.dispose();
    _keywordsController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<GenerateCvViewModel>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _promptController,
          minLines: 4,
          maxLines: 8,
          decoration: const InputDecoration(
            labelText: 'Prompt để Gemini tạo HTML CV',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề CV'),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: TextField(
                controller: _userIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'UserID'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _keywordsController,
          decoration: const InputDecoration(
            labelText: 'Keywords (phân tách bằng dấu phẩy)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        if (vm.state == ViewState.busy) ...[
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 12),
        ],
        if (vm.state == ViewState.error && vm.errorMessage != null) ...[
          Text('Lỗi: ${vm.errorMessage}', style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
        ],
        ElevatedButton(
          onPressed: vm.state == ViewState.busy ? null : () async {
            final prompt = _promptController.text.trim();
            if (prompt.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập prompt')));
              return;
            }
            await vm.generatePdfFromPrompt(prompt);
            if (vm.state == ViewState.error) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: ${vm.errorMessage}')));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF đã được mở')));
            }
          },
          child: const Text('Tạo và Xuất PDF từ Prompt'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: vm.state == ViewState.busy ? null : () async {
            final userId = int.tryParse(_userIdController.text) ?? 1;
            final title = _titleController.text.trim();
            final keywords = _keywordsController.text
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
            final dto = CreateUserCvDto(
              userId: userId,
              title: title,
              keywords: keywords.isEmpty ? null : keywords,
            );
            await vm.createCv(dto);
            if (vm.state == ViewState.error) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: ${vm.errorMessage}')));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tạo CV thành công')));
            }
          },
          child: const Text('Tạo CV với Keywords (Lưu vào hệ thống)'),
        ),
      ],
    );
  }
}
