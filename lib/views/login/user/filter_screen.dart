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
  // Controllers
  late TextEditingController _locationController;
  late TextEditingController _minSalaryController;
  late TextEditingController _maxSalaryController;

  // Biến chọn Job Type
  String? _selectedJobType;
  final List<String> _jobTypes = [
    'Full-time',
    'Part-time',
    'Internship',
    'Contract',
    'Freelance'
  ];

  @override
  void initState() {
    super.initState();
    // Lấy giá trị bộ lọc hiện tại từ ViewModel để điền vào form
    final vm = context.read<HomeViewModel>();
    final currentFilter = vm.currentFilter;

    _locationController = TextEditingController(text: currentFilter.location);
    _minSalaryController = TextEditingController(
        text: currentFilter.salary_min != null ? currentFilter.salary_min.toString() : '');
    _maxSalaryController = TextEditingController(
        text: currentFilter.salary_max != null ? currentFilter.salary_max.toString() : '');

    _selectedJobType = currentFilter.job_type;
  }

  @override
  void dispose() {
    _locationController.dispose();
    _minSalaryController.dispose();
    _maxSalaryController.dispose();
    super.dispose();
  }

  // Hàm xử lý Áp dụng
  void _applyFilters() {
    final vm = context.read<HomeViewModel>();

    // Tạo DTO từ dữ liệu nhập
    final dto = FilterJobDto(
      location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      salary_min: double.tryParse(_minSalaryController.text),
      salary_max: double.tryParse(_maxSalaryController.text),
      job_type: _selectedJobType,
    );

    // Gọi ViewModel để lọc
    vm.applyFilter(dto);

    // Đóng màn hình lọc
    Navigator.of(context).pop();
  }

  // Hàm Xóa bộ lọc
  void _clearFilters() {
    final vm = context.read<HomeViewModel>();

    // Reset về mặc định (Load lại danh sách ban đầu)
    vm.fetchJobs();

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // UI Bottom Sheet
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // Tránh bàn phím che
        left: 20,
        right: 20,
        top: 10,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thanh gạt nhỏ phía trên
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const Text(
              'Bộ Lọc Tìm Kiếm',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // 1. Địa điểm
            _buildSectionTitle('Địa điểm'),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Nhập thành phố (VD: Ho Chi Minh)',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Loại công việc (Chips)
            _buildSectionTitle('Loại công việc'),
            Wrap(
              spacing: 8.0,
              runSpacing: 0.0,
              children: _jobTypes.map((type) {
                final isSelected = _selectedJobType == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedJobType = selected ? type : null;
                    });
                  },
                  selectedColor: const Color(0xFF00C89C).withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFF00897B) : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF00C89C) : Colors.transparent,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 3. Mức lương (Range)
            _buildSectionTitle('Mức lương (VND/USD)'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minSalaryController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Thấp nhất',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('-', style: TextStyle(fontSize: 20, color: Colors.grey)),
                ),
                Expanded(
                  child: TextField(
                    controller: _maxSalaryController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Cao nhất',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 4. Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Xóa bộ lọc', style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C89C),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Áp dụng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}