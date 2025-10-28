// lib/views/home/filter_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:job_seeker_frontend/view_models/user/home_view_model.dart';

import '../../../dto/filter_job_dto.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({Key? key}) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // Controllers cho các trường text
  late TextEditingController _locationController;
  late TextEditingController _minSalaryController;
  late TextEditingController _maxSalaryController;

  // Biến cho radio button
  String? _selectedJobType;

  // Các lựa chọn cho job_type (từ DTO)
  final List<String> _jobTypes = ['Full-time', 'Part-time', 'Internship', 'Contract','Freelance'];

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị ban đầu từ ViewModel (nếu người dùng đã lọc)
    final vm = context.read<HomeViewModel>();
    final filter = vm.currentFilter;

    _locationController = TextEditingController(text: filter.location);
    _minSalaryController = TextEditingController(text: filter.salary_min?.toString() ?? '');
    _maxSalaryController = TextEditingController(text: filter.salary_max?.toString() ?? '');
    _selectedJobType = filter.job_type;
  }

  @override
  void dispose() {
    _locationController.dispose();
    _minSalaryController.dispose();
    _maxSalaryController.dispose();
    super.dispose();
  }

  // Hàm xử lý khi nhấn "Apply"
  void _applyFilters() {
    final vm = context.read<HomeViewModel>();

    final dto = FilterJobDto(
      location: _locationController.text.trim(),
      salary_min: num.tryParse(_minSalaryController.text),
      salary_max: num.tryParse(_maxSalaryController.text),
      job_type: _selectedJobType,
    );

    // Gọi VM để áp dụng filter
    vm.applyFilter(dto);
    Navigator.of(context).pop(); // Đóng bottom sheet
  }

  // Hàm xử lý khi nhấn "Clear All"
  void _clearFilters() {
    final vm = context.read<HomeViewModel>();
    // Gọi fetchJobs() để reset về trang 1 và xóa filter
    vm.fetchJobs();
    Navigator.of(context).pop(); // Đóng bottom sheet
  }

  @override
  Widget build(BuildContext context) {
    // Padding để tránh bàn phím che mất UI
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thanh gạt (giống trong ảnh)
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Tiêu đề (giống trong ảnh)
            const Text(
              'Filter',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // --- TRƯỜNG LỌC 1: LOCATION (Từ DTO) ---
            _buildSectionTitle('Location'),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: 'E.g., Ho Chi Minh City, Hanoi...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 20),

            // --- TRƯỜNG LỌC 2: JOB TYPE (Từ DTO) ---
            // (Phần này thay cho "Experience Level" trong ảnh)
            _buildSectionTitle('Job Type'),
            Wrap(
              spacing: 8.0, // Khoảng cách ngang giữa các chip
              runSpacing: 4.0, // Khoảng cách dọc
              children: _jobTypes.map((type) {
                final isSelected = _selectedJobType == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (isSelected) {
                    setState(() {
                      _selectedJobType = isSelected ? type : null;
                    });
                  },
                  selectedColor: Colors.teal[100], // Màu khi được chọn
                  backgroundColor: Colors.grey[100],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.teal[900] : Colors.black,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // --- TRƯỜNG LỌC 3: SALARY RANGE (Từ DTO) ---
            // (Phần này không có trong ảnh nhưng CẦN THIẾT cho backend)
            _buildSectionTitle('Salary Range (VND)'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minSalaryController,
                    decoration: const InputDecoration(
                      labelText: 'Min Salary',
                      hintText: '10000000',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _maxSalaryController,
                    decoration: const InputDecoration(
                      labelText: 'Max Salary',
                      hintText: '50000000',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // --- BUTTONS (Giống trong ảnh) ---
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearFilters, // Gọi hàm xóa filter
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters, // Gọi hàm áp dụng
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal, // Màu xanh
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Apply', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30), // Đệm dưới
          ],
        ),
      ),
    );
  }

  // Widget hỗ trợ cho tiêu đề
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}