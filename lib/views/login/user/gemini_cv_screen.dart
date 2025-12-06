import 'package:flutter/material.dart';

class GeminiCvScreen extends StatefulWidget {
  const GeminiCvScreen({super.key});

  @override
  State<GeminiCvScreen> createState() => _GeminiCvScreenState();
}

class _GeminiCvScreenState extends State<GeminiCvScreen> {
  final TextEditingController _promptController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'role': 'ai', 'content': 'Chào bạn! Tôi là trợ lý AI. Bạn muốn tôi giúp viết phần nào trong CV? (Ví dụ: Mục tiêu nghề nghiệp, Kinh nghiệm làm việc...)'}
  ];
  bool _isLoading = false;

  void _sendMessage() async {
    if (_promptController.text.trim().isEmpty) return;

    final userMsg = _promptController.text;
    setState(() {
      _messages.add({'role': 'user', 'content': userMsg});
      _isLoading = true;
      _promptController.clear();
    });

    // Giả lập gọi API Gemini
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _messages.add({
        'role': 'ai',
        'content': 'Dựa trên thông tin của bạn "$userMsg", tôi gợi ý bạn viết như sau:\n\n- Đã từng làm việc với NestJS và Flutter.\n- Có kinh nghiệm xây dựng hệ thống backend scalable.'
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trợ lý AI Gemini'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    child: Text(
                      msg['content']!,
                      style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    decoration: InputDecoration(
                      hintText: 'Nhập yêu cầu...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  mini: true,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}