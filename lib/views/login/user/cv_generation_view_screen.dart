//
// 📄 [SỬA ĐỔI] baptt123/jobseekerfrontend/JobSeekerFrontEnd-develop/lib/views/login/user/cv_generation_view_screen.dart
//
import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/dto/create_cv_dto.dart';
import 'package:provider/provider.dart';
import 'package:job_seeker_frontend/view_models/user/cv_generation_view_model.dart';
import 'package:job_seeker_frontend/views/login/user/cv_preview_screen.dart';

import '../../../dto/education_dto.dart';
import '../../../dto/experience_dto.dart';
import '../../../dto/skill_dto.dart'; // Màn hình xem trước

class CvGenerationViewScreen extends StatefulWidget {
  final String templateId; // Nhận ID từ màn hình trước

  const CvGenerationViewScreen({Key? key, required this.templateId}) : super(key: key);

  @override
  State<CvGenerationViewScreen> createState() => _CvGenerationViewScreenState();
}

class _CvGenerationViewScreenState extends State<CvGenerationViewScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers cho Form
  final _fullNameC = TextEditingController(text: 'Nguyễn Văn A (Test User 1)');
  final _jobTitleC = TextEditingController(text: 'Lập trình viên Flutter');
  final _emailC = TextEditingController(text: 'user1@test.com');
  final _phoneC = TextEditingController(text: '0987654321');
  final _addressC = TextEditingController(text: '123 Đường ABC, Quận 1, TP. HCM');
  final _summaryC = TextEditingController(text: 'Là một lập trình viên có kinh nghiệm...');

  // Chúng ta sẽ quản lý danh sách kinh nghiệm, học vấn, kỹ năng
  // (Để đơn giản, tôi khởi tạo sẵn 1 vài mục)
  List<ExperienceDto> _experiences = [
    ExperienceDto(jobTitle: 'Junior Developer', company: 'Công ty ABC', duration: '2022 - 2023', description: 'Phát triển ứng dụng...')
  ];
  List<EducationDto> _educations = [
    EducationDto(school: 'Đại học XYZ', degree: 'Kỹ sư CNTT', duration: '2018 - 2022')
  ];
  List<SkillDto> _skills = [
    SkillDto(name: 'Flutter'), SkillDto(name: 'Dart'), SkillDto(name: 'NestJS')
  ];

  @override
  void initState() {
    super.initState();
    // Khởi tạo ViewModel (nếu cần, nhưng giờ chúng ta gọi service trực tiếp)
  }

  void _onPreview() async {
    if (_formKey.currentState!.validate()) {
      // Tạo DTO từ dữ liệu form
      final cvData = CreateCvDto(
        fullName: _fullNameC.text,
        jobTitle: _jobTitleC.text,
        email: _emailC.text,
        phone: _phoneC.text,
        address: _addressC.text,
        summary: _summaryC.text,
        experiences: _experiences,
        educations: _educations,
        skills: _skills,
      );

      // Lấy ViewModel để gọi service
      final viewModel = Provider.of<CvGenerationViewModel>(context, listen: false);

      // Hiển thị loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      try {
        // Gọi service qua ViewModel
        final htmlContent = await viewModel.previewCv(widget.templateId, cvData);

        // Tắt loading
        Navigator.pop(context);

        // Chuyển sang màn hình Preview
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CvPreviewScreen(
              htmlContent: htmlContent,
              cvData: cvData, // Truyền cvData sang để dùng cho lúc tải về
              templateId: widget.templateId,
            ),
          ),
        );

      } catch (e) {
        // Tắt loading
        Navigator.pop(context);
        // Hiển thị lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nhập thông tin CV'),
        actions: [
          IconButton(
            icon: Icon(Icons.visibility),
            onPressed: _onPreview,
            tooltip: 'Xem trước CV',
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text('Mẫu đã chọn: ${widget.templateId}', style: TextStyle(fontSize: 16, color: Colors.blue.shade800)),
            SizedBox(height: 16),
            Text('Thông tin cá nhân', style: Theme.of(context).textTheme.headlineSmall),
            _buildTextFormField(_fullNameC, 'Họ và tên'),
            _buildTextFormField(_jobTitleC, 'Vị trí mong muốn'),
            _buildTextFormField(_emailC, 'Email', keyboardType: TextInputType.emailAddress),
            _buildTextFormField(_phoneC, 'Số điện thoại', keyboardType: TextInputType.phone),
            _buildTextFormField(_addressC, 'Địa chỉ'),
            _buildTextFormField(_summaryC, 'Giới thiệu / Mục tiêu', maxLines: 5),

            Divider(height: 30),
            // TODO: Xây dựng giao diện để thêm/sửa/xóa Kinh nghiệm, Học vấn, Kỹ năng
            // Hiện tại chỉ hiển thị dữ liệu đã hardcode
            Text('Kinh nghiệm (Tạm thời hardcode)', style: Theme.of(context).textTheme.headlineSmall),
            ..._experiences.map((e) => ListTile(title: Text(e.jobTitle), subtitle: Text(e.company))),

            Divider(height: 30),
            Text('Học vấn (Tạm thời hardcode)', style: Theme.of(context).textTheme.headlineSmall),
            ..._educations.map((e) => ListTile(title: Text(e.school), subtitle: Text(e.degree))),

            Divider(height: 30),
            Text('Kỹ năng (Tạm thời hardcode)', style: Theme.of(context).textTheme.headlineSmall),
            Wrap(
              spacing: 8,
              children: _skills.map((s) => Chip(label: Text(s.name))).toList(),
            ),

            SizedBox(height: 30),
            ElevatedButton.icon(
              icon: Icon(Icons.visibility),
              label: Text('Xem trước'),
              onPressed: _onPreview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label, {TextInputType? keyboardType, int? maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập $label';
          }
          return null;
        },
      ),
    );
  }
}