// lib/views/login/user/filter_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:job_seeker_frontend/view_models/user/home_view_model.dart';
import '../../../dto/filter_job_dto.dart';

const Color kPrimaryColor = Color(0xFF6C63FF);
const Color kSurfaceColor = Color(0xFFF8F9FE);

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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 24),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Bộ lọc tìm kiếm", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text("Đặt lại", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                )
              ],
            ),
            const Divider(height: 30),

            // 1. Địa điểm
            _buildSectionLabel("Địa điểm"),
            const SizedBox(height: 8),
            _buildInputField(
              controller: _locationController,
              hint: "VD: Ho Chi Minh, Ha Noi",
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 24),

            // 2. Mức lương
            _buildSectionLabel("Mức lương (USD)"),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildInputField(controller: _minSalaryController, hint: "Min", isNumber: true)),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("-", style: TextStyle(fontSize: 20, color: Colors.grey))),
                Expanded(child: _buildInputField(controller: _maxSalaryController, hint: "Max", isNumber: true)),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Loại hình công việc
            _buildSectionLabel("Loại hình công việc"),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _jobTypes.map((type) {
                final isSelected = _selectedJobType == type;
                return ChoiceChip(
                  label: Text(type),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  selected: isSelected,
                  onSelected: (selected) => setState(() => _selectedJobType = selected ? type : null),
                  selectedColor: kPrimaryColor,
                  backgroundColor: kSurfaceColor,
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

  Widget _buildSectionLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87));
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool isNumber = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
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