import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../view_models/user/job_detail_view_model.dart';
import '../../../views/login/user/login_screen.dart';

const Color kPrimaryColor = Color(0xFF6C63FF);

class CommentSection extends StatefulWidget {
  final int jobId;
  const CommentSection({Key? key, required this.jobId}) : super(key: key);

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _ctrl = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Logic fetch đã được gọi ở JobDetailViewModel.fetchJobDetail
    // Nhưng để chắc chắn, nếu list rỗng thì gọi load lại
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<JobDetailViewModel>(context, listen: false);
      if (vm.comments.isEmpty && !vm.isLoadingComments) {
        vm.loadComments(widget.jobId);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lấy ViewModel từ Provider
    final vm = Provider.of<JobDetailViewModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(thickness: 8, color: Colors.black12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: const [
              Icon(Icons.forum_outlined, color: kPrimaryColor),
              SizedBox(width: 8),
              Text(
                "Hỏi đáp & Bình luận",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // 1. Danh sách Comment
        if (vm.isLoadingComments)
          const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: kPrimaryColor)))
        else if (vm.comments.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            alignment: Alignment.center,
            child: const Text("Chưa có bình luận nào. Hãy là người đầu tiên!", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          )
        else
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Để scroll theo parent widget
            itemCount: vm.comments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, index) {
              final comment = vm.comments[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(radius: 14, backgroundColor: Colors.grey[400], child: const Icon(Icons.person, color: Colors.white, size: 18)),
                        const SizedBox(width: 8),
                        Text(comment.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const Spacer(),
                        Text(DateFormat('dd/MM HH:mm').format(comment.createdAt), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(comment.content, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              );
            },
          ),

        const SizedBox(height: 20),

        // 2. Input nhập liệu
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: vm.isLoggedIn
              ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: "Nhập thắc mắc...",
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: kPrimaryColor)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: _isSending ? Colors.grey : kPrimaryColor,
                radius: 24,
                child: IconButton(
                  icon: _isSending
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  onPressed: _isSending
                      ? null
                      : () async {
                    final text = _ctrl.text.trim();
                    if (text.isNotEmpty) {
                      setState(() => _isSending = true);
                      FocusScope.of(context).unfocus(); // Ẩn bàn phím

                      bool success = await vm.sendComment(context, text);

                      if (mounted) {
                        setState(() => _isSending = false);
                        if (success) _ctrl.clear();
                      }
                    }
                  },
                ),
              ),
            ],
          )
              : Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              children: [
                const Text("Bạn cần đăng nhập để gửi câu hỏi.", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.login, size: 18),
                  label: const Text("Đăng nhập ngay"),
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())).then((_) {
                      vm.checkLoginStatus(); // Check lại sau khi quay về
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}