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

  void _applyFilters() {
    final vm = context.read<HomeViewModel>();
    final dto = FilterJobDto(
      location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      salary_min: double.tryParse(_minSalaryController.text),
      salary_max: double.tryParse(_maxSalaryController.text),
      job_type: _selectedJobType,
    );
    vm.applyFilter(dto);
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    final vm = context.read<HomeViewModel>();
    vm.fetchInitialData();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Lấy theme hiện tại để hỗ trợ Dark Mode
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Màu nền cho các input field
    final inputFillColor = isDark ? Colors.grey[800] : Colors.white;
    final chipBackgroundColor = isDark ? Colors.grey[800] : Colors.grey[100];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
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
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            Text(
              'Bộ Lọc Tìm Kiếm',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // 1. Địa điểm
            _buildSectionTitle('Địa điểm', theme),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Nhập thành phố (VD: Ho Chi Minh)',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.location_on_outlined, color: theme.iconTheme.color),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: inputFillColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Loại công việc (Chips)
            _buildSectionTitle('Loại công việc', theme),
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
                  // Màu sắc tương thích Dark Mode
                  selectedColor: const Color(0xFF00C89C).withOpacity(0.2),
                  backgroundColor: chipBackgroundColor,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? const Color(0xFF00897B)
                        : theme.textTheme.bodyMedium?.color,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
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
            _buildSectionTitle('Mức lương (VND/USD)', theme),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minSalaryController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Thấp nhất',
                      filled: true,
                      fillColor: inputFillColor,
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
                      filled: true,
                      fillColor: inputFillColor,
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
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Xóa bộ lọc', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
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

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}