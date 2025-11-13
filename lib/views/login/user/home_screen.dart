import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ THÊM IMPORT NÀY
import 'package:job_seeker_frontend/views/login/user/search_screen.dart';
import 'package:provider/provider.dart';

import '../../../view_models/user/home_view_model.dart';
import '../../../widget/user/home/home_bottom_nav.dart';
import '../../../widget/user/home/home_header.dart';
import '../../../widget/user/home/job_list.dart';
import '../../../widget/user/home/search_title.dart';
import 'conversation_list_screen.dart';
import 'filter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ✅ 1. XÓA ScrollController VÀ CÁC HÀM LIÊN QUAN
  // final ScrollController _scrollController = ScrollController(); // Không dùng nữa

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Dùng fetchInitialData hoặc fetchJobs đều được
      context.read<HomeViewModel>().fetchJobs();
    });
    // _scrollController.addListener(_onScroll); // Không dùng nữa
  }

  // void _onScroll() { ... } // Không dùng nữa

  @override
  void dispose() {
    // _scrollController.removeListener(_onScroll); // Không dùng nữa
    // _scrollController.dispose(); // Không dùng nữa
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00C89C),
        elevation: 0,
        title: const Text('Trang chủ',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            tooltip: 'Lọc công việc',
            onPressed: () => _showFilterScreen(context),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            tooltip: 'Tin nhắn',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConversationListScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, vm, child) {
          if (vm.state == HomeState.loading && vm.jobs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.state == HomeState.error && vm.jobs.isEmpty) {
            return Center(child: Text('Đã xảy ra lỗi: ${vm.errorMessage}'));
          }

          // ✅ 2. HIỂN THỊ OVERLAY KHI CHUYỂN TRANG
          bool isLoading = vm.state == HomeState.loading;

          return Stack(
            children: [
              _buildBody(context, vm),
              // Nếu đang tải (kể cả chuyển trang) thì che mờ
              if (isLoading && vm.jobs.isNotEmpty)
                Container(
                  color: Colors.black.withOpacity(0.1),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: const HomeBottomNav(),
    );
  }

  Widget _buildBody(BuildContext context, HomeViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            const HomeHeader(),
            Positioned(
              // (Code search bar của bạn)
              top: 100,
              left: 20,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                },
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey[600]),
                      const SizedBox(width: 12),
                      Text(
                        'Tìm kiếm công việc...',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 120),
        const SectionTitle('Available Jobs'),
        const SizedBox(height: 16),
        Expanded(
          // ✅ 3. XÓA ScrollController KHỎI JobsList
          // (Nhớ cập nhật file job_list.dart để bỏ 'required scrollController')
          child: JobsList(),
        ),

        // ✅ 4. THÊM ĐIỀU KHIỂN PHÂN TRANG
        // Chỉ hiển thị khi KHÔNG LỌC và có nhiều hơn 1 trang
        if (!vm.isFiltered && vm.totalPages > 1)
          _buildPaginationControls(context, vm),
      ],
    );
  }

  // ✅ 5. WIDGET MỚI ĐỂ HIỂN THỊ CÁC NÚT PHÂN TRANG (CÓ NHẬP SỐ)
  Widget _buildPaginationControls(BuildContext context, HomeViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút "Trang trước"
          TextButton.icon(
            icon: const Icon(Icons.arrow_back_ios, size: 16),
            label: const Text('Trước'),
            onPressed: vm.currentPage > 1
                ? () {
              vm.goToPage(vm.currentPage - 1);
            }
                : null,
            style: TextButton.styleFrom(
              foregroundColor: vm.currentPage > 1 ? Colors.blue : Colors.grey,
            ),
          ),

          // Nút "Trang X / Y" có thể nhấn
          TextButton(
            onPressed: () {
              // Gọi hàm hiển thị dialog
              _showGoToPageDialog(context, vm);
            },
            child: Text(
              'Trang ${vm.currentPage} / ${vm.totalPages}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue, // Màu xanh để biết có thể nhấn
                decoration: TextDecoration.underline,
              ),
            ),
          ),

          // Nút "Trang sau"
          TextButton.icon(
            label: const Icon(Icons.arrow_forward_ios, size: 16),
            icon: const Text('Sau'),
            onPressed: vm.currentPage < vm.totalPages
                ? () {
              vm.goToPage(vm.currentPage + 1);
            }
                : null,
            style: TextButton.styleFrom(
              foregroundColor:
              vm.currentPage < vm.totalPages ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ 6. HÀM MỚI ĐỂ HIỂN THỊ DIALOG NHẬP SỐ TRANG
  void _showGoToPageDialog(BuildContext context, HomeViewModel vm) {
    final _controller = TextEditingController(text: vm.currentPage.toString());
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Đi đến trang'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Nhập số trang (1 - ${vm.totalPages})',
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số';
                }
                final page = int.tryParse(value);
                if (page == null) {
                  return 'Số không hợp lệ';
                }
                if (page < 1 || page > vm.totalPages) {
                  return 'Trang phải từ 1 đến ${vm.totalPages}';
                }
                return null; // Hợp lệ
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newPage = int.parse(_controller.text);
                  Navigator.pop(ctx);
                  vm.goToPage(newPage);
                }
              },
              child: const Text('Đi đến'),
            ),
          ],
        );
      },
    );
  }

  // (Hàm _showFilterScreen giữ nguyên)
  void _showFilterScreen(BuildContext context) {
    final vm = context.read<HomeViewModel>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return ChangeNotifierProvider.value(
          value: vm,
          child: const FilterScreen(),
        );
      },
    );
  }
}