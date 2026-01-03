// lib/views/login/user/filter_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:job_seeker_frontend/view_models/user/home_view_model.dart';
import '../../../dto/filter_job_dto.dart';

const Color kPrimaryColor = Color(0xFF6C63FF);

class FilterScreen extends StatefulWidget {
  const FilterScreen({Key? key}) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late TextEditingController _locationController;
  late TextEditingController _minSalaryController;
  late TextEditingController _maxSalaryController;
  String? _selectedJobType;

  final List<String> _jobTypes = ['Full-time', 'Part-time', 'Internship', 'Contract', 'Freelance'];

  @override
  void initState() {
    super.initState();
    final vm = context.read<HomeViewModel>();
    final currentFilter = vm.currentFilter;

    _locationController = TextEditingController(text: currentFilter.location);
    _minSalaryController = TextEditingController(text: currentFilter.salary_min?.toString() ?? '');
    _maxSalaryController = TextEditingController(text: currentFilter.salary_max?.toString() ?? '');
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
    context.read<HomeViewModel>().fetchInitialData();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Màu nền cho các khối input (TextField, Chips)
    final surfaceColor = isDark ? Colors.grey[800] : const Color(0xFFF8F9FE);
    final textColor = theme.textTheme.bodyLarge?.color;

    return Container(
      decoration: BoxDecoration(
        // Màu nền của BottomSheet
        color: theme.cardTheme.color, // Trắng (Light) hoặc Xám Card (Dark)
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 24,
        right: 24,
        top: 12,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                    color: isDark ? Colors.grey[600] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10)
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Bộ lọc tìm kiếm", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text("Đặt lại", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                )
              ],
            ),
            const Divider(height: 30),

            // 1. Địa điểm
            _buildSectionLabel(context, "Địa điểm"),
            const SizedBox(height: 8),
            _buildInputField(
              context,
              controller: _locationController,
              hint: "VD: Ho Chi Minh, Ha Noi",
              icon: Icons.location_on_outlined,
              bgColor: surfaceColor,
            ),
            const SizedBox(height: 24),

            // 2. Mức lương
            _buildSectionLabel(context, "Mức lương (USD)"),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildInputField(context, controller: _minSalaryController, hint: "Min", isNumber: true, bgColor: surfaceColor)),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("-", style: TextStyle(fontSize: 20, color: Colors.grey))),
                Expanded(child: _buildInputField(context, controller: _maxSalaryController, hint: "Max", isNumber: true, bgColor: surfaceColor)),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Loại hình công việc
            _buildSectionLabel(context, "Loại hình công việc"),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _jobTypes.map((type) {
                final isSelected = _selectedJobType == type;
                return ChoiceChip(
                  label: Text(type),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.black87),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  selected: isSelected,
                  onSelected: (selected) => setState(() => _selectedJobType = selected ? type : null),
                  selectedColor: kPrimaryColor,
                  // Màu nền khi chưa chọn
                  backgroundColor: surfaceColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isSelected ? kPrimaryColor : Colors.transparent),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                );
              }).toList(),
            ),

            const SizedBox(height: 40),

            // 4. Button Áp dụng
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: kPrimaryColor.withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Áp dụng bộ lọc", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String text) {
    return Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color));
  }

  Widget _buildInputField(
      BuildContext context, {
        required TextEditingController controller,
        required String hint,
        IconData? icon,
        bool isNumber = false,
        Color? bgColor,
      }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
        style: TextStyle(color: theme.textTheme.bodyLarge?.color), // Màu chữ nhập
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600], size: 20) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}