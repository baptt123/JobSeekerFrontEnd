import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../view_models/user/cv_generation_view_model.dart';
import '../../../view_models/user/user_profile_view_model.dart';
import '../../../utils/app_colors.dart';
import 'cv_preview_screen.dart';
import '../../../dto/create_cv_dto.dart';
import '../../../dto/education_dto.dart';
import '../../../dto/experience_dto.dart';
import '../../../dto/skill_dto.dart';
import '../../../dto/project_dto.dart';
import '../../../dto/achievement_dto.dart';

class CvGenerationViewScreen extends StatefulWidget {
  @override
  _CvGenerationViewScreenState createState() => _CvGenerationViewScreenState();
}

class _CvGenerationViewScreenState extends State<CvGenerationViewScreen> {
  int _currentStep = 0;
  int _selectedTemplateId = 1;

  // Controllers Thông tin cá nhân
  final _nameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _summaryController = TextEditingController();

  // Lists dữ liệu động
  List<SkillDto> _skills = [];
  List<EducationDto> _educations = [];
  List<ExperienceDto> _experiences = [];
  List<ProjectDto> _projects = [];
  List<AchievementDto> _achievements = [];

  // Quản lý ảnh
  File? _selectedImageFile;
  bool _useProfileImage = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userVM = Provider.of<ProfileViewModel>(context, listen: false);
      if (userVM.user != null) {
        _nameController.text = userVM.user!.fullName;
        _emailController.text = userVM.user!.email;
        _phoneController.text = userVM.user!.phone ?? "";
        _addressController.text = userVM.user!.city ?? "";
      }
    });
  }

  // --- LOGIC ẢNH ---
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImageFile = File(image.path);
        _useProfileImage = false;
      });
    }
  }

  // --- SUBMIT ---
  void _submit(CvGenerationViewModel viewModel) async {
    String? profileAvatarUrl;
    if (_useProfileImage) {
      profileAvatarUrl = Provider.of<ProfileViewModel>(context, listen: false).user?.avatarUrl;
    }

    CreateCvDto cvData = CreateCvDto(
      fullName: _nameController.text.trim(),
      jobTitle: _jobTitleController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      summary: _summaryController.text.trim(),
      skills: _skills,
      educations: _educations,
      experiences: _experiences,
      projects: _projects,
      achievements: _achievements,
    );

    File? pdfFile = await viewModel.generateCvFromTemplate(
      _selectedTemplateId,
      cvData,
      localImageFile: _selectedImageFile,
      onlineImageUrl: profileAvatarUrl,
    );

    if (pdfFile != null && mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => CvPreviewScreen(localPath: pdfFile.path)));
    } else if (viewModel.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!), backgroundColor: Colors.red));
    }
  }

  // --- DIALOGS (Có AI) ---
  void _showAddExperienceDialog(BuildContext context, CvGenerationViewModel vm) {
    final jobCtrl = TextEditingController();
    final companyCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text("Thêm Kinh Nghiệm"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            _buildTextField(jobCtrl, "Chức vụ", Icons.work),
            _buildTextField(companyCtrl, "Công ty", Icons.business),
            _buildTextField(durationCtrl, "Thời gian", Icons.date_range),
            _buildAiField(ctx, vm, descCtrl, "Mô tả công việc", "exp", jobCtrl),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Hủy")),
        ElevatedButton(onPressed: () {
          setState(() => _experiences.add(ExperienceDto(
              jobTitle: jobCtrl.text, company: companyCtrl.text,
              duration: durationCtrl.text, description: descCtrl.text
          )));
          Navigator.pop(ctx);
        }, child: Text("Thêm")),
      ],
    ));
  }

  void _showAddProjectDialog(BuildContext context, CvGenerationViewModel vm) {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final linkCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text("Thêm Dự Án"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            _buildTextField(nameCtrl, "Tên dự án", Icons.folder),
            _buildTextField(roleCtrl, "Vai trò", Icons.person),
            _buildTextField(linkCtrl, "Link Demo/Git", Icons.link),
            _buildAiField(ctx, vm, descCtrl, "Mô tả dự án", "project", nameCtrl),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Hủy")),
        ElevatedButton(onPressed: () {
          setState(() => _projects.add(ProjectDto(
              name: nameCtrl.text, role: roleCtrl.text,
              description: descCtrl.text, link: linkCtrl.text
          )));
          Navigator.pop(ctx);
        }, child: Text("Thêm")),
      ],
    ));
  }

  // --- WIDGETS ---
  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label, prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildAiField(BuildContext ctx, CvGenerationViewModel vm, TextEditingController ctrl, String label, String type, TextEditingController contextCtrl) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        _buildTextField(ctrl, label, Icons.description, maxLines: 3),
        IconButton(
          icon: Icon(Icons.auto_awesome, color: Colors.purple),
          tooltip: "Dùng AI viết",
          onPressed: () async {
            if (contextCtrl.text.isEmpty) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text("Nhập tên/chức vụ trước để AI hiểu!")));
              return;
            }
            String res = await vm.generateAiDescription(contextCtrl.text, type);
            ctrl.text = res;
          },
        )
      ],
    );
  }

  Widget _buildListItem(String title, String subtitle, VoidCallback onDelete) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: onDelete),
      ),
    );
  }

  List<Step> _getSteps(CvGenerationViewModel vm) {
    return [
      Step(
        title: Text("Mẫu"),
        content: SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _templateCard(1, "Modern", Colors.blue[100]!),
              _templateCard(2, "Classic", Colors.grey[200]!),
              _templateCard(3, "Pro", Colors.indigo[100]!),
              _templateCard(4, "Creative", Colors.teal[100]!),
            ],
          ),
        ),
        isActive: _currentStep >= 0, state: _currentStep > 0 ? StepState.complete : StepState.editing,
      ),
      Step(
        title: Text("Cá nhân"),
        content: Column(
          children: [
            Row(children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: _selectedImageFile != null ? FileImage(_selectedImageFile!) :
                (_useProfileImage ? NetworkImage(Provider.of<ProfileViewModel>(context).user?.avatarUrl ?? "") : null) as ImageProvider?,
                child: (_selectedImageFile == null && !_useProfileImage) ? Icon(Icons.person) : null,
              ),
              SizedBox(width: 10),
              TextButton.icon(onPressed: _pickImage, icon: Icon(Icons.upload), label: Text("Chọn ảnh")),
              Checkbox(value: _useProfileImage, onChanged: (v) => setState(() { _useProfileImage = v!; if(v) _selectedImageFile = null; })),
              Text("Ảnh hồ sơ"),
            ]),
            SizedBox(height: 10),
            _buildTextField(_nameController, "Họ tên", Icons.person),
            _buildTextField(_jobTitleController, "Vị trí", Icons.work),
            _buildTextField(_emailController, "Email", Icons.email),
            _buildTextField(_phoneController, "SĐT", Icons.phone),
            _buildTextField(_addressController, "Địa chỉ", Icons.location_on),
            _buildAiField(context, vm, _summaryController, "Giới thiệu", "summary", _jobTitleController),
          ],
        ),
        isActive: _currentStep >= 1, state: _currentStep > 1 ? StepState.complete : StepState.editing,
      ),
      Step(
        title: Text("Chi tiết"),
        content: Column(
          children: [
            // Kỹ năng
            TextField(
              decoration: InputDecoration(labelText: "Kỹ năng (cách nhau dấu phẩy)", border: OutlineInputBorder()),
              onChanged: (v) => _skills = v.split(',').map((e) => SkillDto(name: e.trim())).toList(),
            ),
            SizedBox(height: 10),
            // Kinh nghiệm
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Kinh nghiệm", style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(icon: Icon(Icons.add_circle, color: AppColors.primary), onPressed: () => _showAddExperienceDialog(context, vm)),
            ]),
            ..._experiences.map((e) => _buildListItem(e.jobTitle, e.company, () => setState(() => _experiences.remove(e)))),

            // Dự án
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Dự án cá nhân", style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(icon: Icon(Icons.add_circle, color: AppColors.primary), onPressed: () => _showAddProjectDialog(context, vm)),
            ]),
            ..._projects.map((e) => _buildListItem(e.name, e.role, () => setState(() => _projects.remove(e)))),
          ],
        ),
        isActive: _currentStep >= 2, state: _currentStep == 2 ? StepState.editing : StepState.indexed,
      ),
    ];
  }

  Widget _templateCard(int id, String name, Color color) {
    bool selected = _selectedTemplateId == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedTemplateId = id),
      child: Container(
        width: 100, margin: EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(10),
            border: selected ? Border.all(color: AppColors.primary, width: 2) : null
        ),
        child: Center(child: Text(name, style: TextStyle(fontWeight: FontWeight.bold))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CvGenerationViewModel(),
      child: Scaffold(
        appBar: AppBar(title: Text("Tạo CV Chuyên Nghiệp"), backgroundColor: AppColors.primary),
        body: Consumer<CvGenerationViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) return Center(child: CircularProgressIndicator());
            return Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 2) setState(() => _currentStep++);
                else _submit(vm);
              },
              onStepCancel: () {
                if (_currentStep > 0) setState(() => _currentStep--);
              },
              steps: _getSteps(vm),
              controlsBuilder: (ctx, details) => Padding(
                padding: EdgeInsets.only(top: 20),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: Text(_currentStep == 2 ? "XUẤT CV" : "TIẾP THEO"),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    ),
                    SizedBox(width: 10),
                    if (_currentStep > 0) TextButton(onPressed: details.onStepCancel, child: Text("QUAY LẠI")),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}