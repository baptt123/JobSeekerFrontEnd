import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_seeker_frontend/view_models/user/cv_generation_view_model.dart';
import 'cv_preview_screen.dart'; // Import màn hình xem PDF

// 🔥 Định nghĩa màu chủ đạo
const Color kPrimaryColor = Color(0xFF6C63FF);
const Color kBackgroundColor = Color(0xFFF2F4F8); // Xám xanh nhạt dịu mắt
const Color kAiBubbleColor = Colors.white;
const Color kUserBubbleColor = kPrimaryColor;

class GeminiCvScreen extends StatefulWidget {
  const GeminiCvScreen({super.key});

  @override
  State<GeminiCvScreen> createState() => _GeminiCvScreenState();
}

class _GeminiCvScreenState extends State<GeminiCvScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Danh sách tin nhắn khởi tạo
  final List<Map<String, String>> _messages = [
    {
      'role': 'ai',
      'content': 'Chào bạn! 👋\nTôi là trợ lý AI chuyên thiết kế CV.\n\nHãy mô tả bản thân bạn (Họ tên, Kinh nghiệm, Kỹ năng...) một cách tự do. Tôi sẽ sắp xếp và tạo ra một CV chuyên nghiệp chuẩn PDF cho bạn ngay lập tức!'
    }
  ];

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Hàm xử lý gửi tin nhắn
  void _handleSendMessage(CvGenerationViewModel vm) async {
    final text = _promptController.text.trim();
    if (text.isEmpty) return;

    // 1. Thêm tin nhắn của User vào list
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _promptController.clear();
    });
    _scrollToBottom();

    // 2. Gọi ViewModel để tạo CV
    // Lưu ý: ViewModel sẽ set state loading -> UI tự cập nhật nhờ Consumer/watch
    final success = await vm.generateCv(text);

    if (!mounted) return;

    // 3. Xử lý kết quả
    if (success && vm.pdfData != null) {
      setState(() {
        _messages.add({
          'role': 'ai',
          'content': 'Tuyệt vời! CV của bạn đã hoàn tất. 📄\nĐang mở bản xem trước...'
        });
      });
      _scrollToBottom();

      // Chờ xíu cho người dùng đọc tin nhắn rồi chuyển trang
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CvPreviewScreen(
            pdfData: vm.pdfData, // Truyền dữ liệu PDF sang màn hình Preview
            title: "CV Thiết kế bởi AI",
          ),
        ),
      );
    } else {
      setState(() {
        _messages.add({
          'role': 'ai',
          'content': 'Rất tiếc, có lỗi xảy ra: ${vm.errorMessage ?? "Lỗi không xác định"}. 😔\nBạn vui lòng thử lại nhé.'
        });
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe trạng thái từ ViewModel
    final vm = context.watch<CvGenerationViewModel>();
    final bool isLoading = vm.state == CvState.loading;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Gemini CV Creator', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // --- 1. VÙNG CHAT ---
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return _buildChatBubble(msg['content']!, isUser);
              },
            ),
          ),

          // --- 2. TRẠNG THÁI LOADING ---
          if (isLoading)
            Container(
              margin: const EdgeInsets.only(bottom: 10, left: 20),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: kPrimaryColor),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Gemini đang phân tích và thiết kế CV...",
                    style: TextStyle(color: Colors.grey[600], fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

          // --- 3. INPUT BAR ---
          _buildInputArea(isLoading, () => _handleSendMessage(vm)),
        ],
      ),
    );
  }

  // Widget bong bóng chat
  Widget _buildChatBubble(String message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? kUserBubbleColor : kAiBubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              const Text("Gemini AI", style: TextStyle(color: kPrimaryColor, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
            ],
            Text(
              message,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget khu vực nhập liệu
  Widget _buildInputArea(bool isLoading, VoidCallback onSend) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 30), // Padding bottom lớn cho safe area
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          // Ô nhập liệu
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: kBackgroundColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.transparent),
              ),
              child: TextField(
                controller: _promptController,
                enabled: !isLoading,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'Nhập thông tin CV của bạn...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Nút Gửi
          GestureDetector(
            onTap: isLoading ? null : onSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isLoading ? Colors.grey[300] : kPrimaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  if (!isLoading)
                    BoxShadow(color: kPrimaryColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))
                ],
              ),
              child: Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}