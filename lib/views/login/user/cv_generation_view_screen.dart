// lib/views/login/user/cv_generation_view_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_seeker_frontend/view_models/user/cv_generation_view_model.dart';
import 'package:job_seeker_frontend/dto/create_cv_dto.dart';
import 'package:job_seeker_frontend/dto/experience_dto.dart';
import 'package:job_seeker_frontend/dto/education_dto.dart';
import 'package:job_seeker_frontend/dto/skill_dto.dart';
import 'package:job_seeker_frontend/views/login/user/cv_preview_screen.dart';

const Color kPrimaryColor = Color(0xFF6C63FF);

class CvGenerationViewScreen extends StatefulWidget {
  final String templateId; // ID mẫu CV (1 hoặc 2)
  const CvGenerationViewScreen({super.key, required this.templateId});

  @override
  State<CvGenerationViewScreen> createState() => _CvGenerationViewScreenState();
}

class _CvGenerationViewScreenState extends State<CvGenerationViewScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _jobTitleCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();

  final List<ExperienceControllers> _expCtrls = [];
  final List<EducationControllers> _eduCtrls = [];
  final List<TextEditingController> _skillCtrls = [];

  @override
  void initState() {
    super.initState();
    _addExperience();
    _addEducation();
    _addSkill();
  }

  void _addExperience() =>
      setState(() => _expCtrls.add(ExperienceControllers()));

  void _removeExperience(int index) =>
      setState(() => _expCtrls.removeAt(index));

  void _addEducation() => setState(() => _eduCtrls.add(EducationControllers()));

  void _removeEducation(int index) => setState(() => _eduCtrls.removeAt(index));

  void _addSkill() => setState(() => _skillCtrls.add(TextEditingController()));

  void _removeSkill(int index) => setState(() => _skillCtrls.removeAt(index));

  void _onSubmit() async {
    // 1. Kiểm tra validation của Form
    if (_formKey.currentState!.validate()) {
      // 2. Map dữ liệu từ các Controller sang DTO
      final dto = CreateCvDto(
        fullName: _nameCtrl.text.trim(),
        jobTitle: _jobTitleCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: _addrCtrl.text.trim(),
        summary: _summaryCtrl.text.trim(),
        // Map danh sách kinh nghiệm
        experiences: _expCtrls.map((e) => e.toDto()).toList(),
        // Map danh sách học vấn
        educations: _eduCtrls.map((e) => e.toDto()).toList(),
        // Map danh sách kỹ năng (lọc bỏ các ô trống)
        skills: _skillCtrls
            .where((s) => s.text.trim().isNotEmpty)
            .map((s) => SkillDto(name: s.text.trim()))
            .toList(),
      );

      // 3. Gọi ViewModel để tạo bản xem trước (Preview)
      final vm = context.read<CvGenerationViewModel>();

      // Lưu ý: widget.templateId được truyền từ màn hình chọn mẫu trước đó
      final success = await vm.generatePreview(widget.templateId, dto);

      // 4. Xử lý kết quả và điều hướng
      if (success && mounted) {
        // Chuyển sang màn hình Preview
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CvPreviewScreen(
              // Dữ liệu PDF (bytes) để hiển thị
              pdfData: vm.previewPdfBytes,
              title: "Xem trước & Tải về", // [UPDATED] Đổi tiêu đề

              // [UPDATED] Bỏ tham số isSaveMode vì logic mới chỉ cho phép tải về client
              templateId: widget.templateId,
              cvData: dto,
            ),
          ),
        );
      } else if (mounted) {
        // Hiển thị lỗi nếu tạo preview thất bại
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.errorMessage ?? 'Lỗi không xác định khi tạo CV'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Hiển thị thông báo nếu form chưa hợp lệ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng kiểm tra lại các trường thông tin bắt buộc'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CvGenerationViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nhập thông tin CV"),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildSectionTitle("Thông tin cá nhân"),
                  _buildTextField(_nameCtrl, "Họ và tên", icon: Icons.person),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _jobTitleCtrl,
                    "Vị trí ứng tuyển",
                    icon: Icons.work,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _emailCtrl,
                    "Email",
                    icon: Icons.email,
                    isEmail: true,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _phoneCtrl,
                    "Số điện thoại",
                    icon: Icons.phone,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _addrCtrl,
                    "Địa chỉ",
                    icon: Icons.location_on,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _summaryCtrl,
                    "Giới thiệu bản thân",
                    icon: Icons.info,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 24),
                  _buildDynamicSectionHeader("Kinh nghiệm", _addExperience),
                  ..._expCtrls.asMap().entries.map(
                        (entry) => _buildExperienceItem(entry.key, entry.value),
                  ),

                  const SizedBox(height: 24),
                  _buildDynamicSectionHeader("Học vấn", _addEducation),
                  ..._eduCtrls.asMap().entries.map(
                        (entry) => _buildEducationItem(entry.key, entry.value),
                  ),

                  const SizedBox(height: 24),
                  _buildDynamicSectionHeader("Kỹ năng", _addSkill),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _skillCtrls
                        .asMap()
                        .entries
                        .map((entry) => _buildSkillItem(entry.key, entry.value))
                        .toList(),
                  ),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: vm.state == CvState.loading ? null : _onSubmit,
                      icon: const Icon(Icons.visibility),
                      label: const Text(
                        "XEM TRƯỚC CV",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (vm.state == CvState.loading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: kPrimaryColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicSectionHeader(String title, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        IconButton(
          onPressed: onAdd,
          icon: const Icon(Icons.add_circle, color: Colors.green),
        ),
      ],
    );
  }

  Widget _buildTextField(
      TextEditingController ctrl,
      String label, {
        IconData? icon,
        int maxLines = 1,
        bool isEmail = false,
      }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      validator: (val) =>
      (val == null || val.isEmpty) ? 'Vui lòng nhập $label' : null,
    );
  }

  Widget _buildExperienceItem(int index, ExperienceControllers ctrls) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_expCtrls.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeExperience(index),
                  ),
              ],
            ),
            _buildTextField(ctrls.title, "Chức danh"),
            const SizedBox(height: 8),
            _buildTextField(ctrls.company, "Công ty"),
            const SizedBox(height: 8),
            _buildTextField(ctrls.duration, "Thời gian"),
            const SizedBox(height: 8),
            _buildTextField(ctrls.desc, "Mô tả", maxLines: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationItem(int index, EducationControllers ctrls) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_eduCtrls.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeEducation(index),
                  ),
              ],
            ),
            _buildTextField(ctrls.school, "Trường học"),
            const SizedBox(height: 8),
            _buildTextField(ctrls.degree, "Bằng cấp"),
            const SizedBox(height: 8),
            _buildTextField(ctrls.duration, "Niên khóa"),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillItem(int index, TextEditingController ctrl) {
    return IntrinsicWidth(
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: "Kỹ năng",
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          suffixIcon: GestureDetector(
            onTap: () => _removeSkill(index),
            child: const Icon(Icons.close, size: 16, color: Colors.red),
          ),
        ),
      ),
    );
  }
}

class ExperienceControllers {
  final title = TextEditingController();
  final company = TextEditingController();
  final duration = TextEditingController();
  final desc = TextEditingController();

  ExperienceDto toDto() => ExperienceDto(
    jobTitle: title.text,
    company: company.text,
    duration: duration.text,
    description: desc.text,
  );
}

class EducationControllers {
  final school = TextEditingController();
  final degree = TextEditingController();
  final duration = TextEditingController();

  EducationDto toDto() => EducationDto(
    school: school.text,
    degree: degree.text,
    duration: duration.text,
  );
}