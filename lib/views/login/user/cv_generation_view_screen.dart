import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart'; // Import Image Picker
import '../../../view_models/user/cv_generation_view_model.dart';
import '../../../view_models/user/user_profile_view_model.dart'; // Để lấy info user
import '../../../utils/app_colors.dart';
import 'cv_preview_screen.dart';

class CvGenerationViewScreen extends StatefulWidget {
  @override
  _CvGenerationViewScreenState createState() => _CvGenerationViewScreenState();
}

class _CvGenerationViewScreenState extends State<CvGenerationViewScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int _currentStep = 0;
  int _selectedTemplateId = 1;

  final _personalInfoKey = GlobalKey<FormState>();
  final _skillsKey = GlobalKey<FormState>();

  // Controllers thông tin cá nhân
  final _nameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _summaryController = TextEditingController();

  // Controllers chi tiết
  final _skillController = TextEditingController();
  final _expCompanyController = TextEditingController();
  final _expJobController = TextEditingController();
  final _expDurationController = TextEditingController();
  final _expDescController = TextEditingController();
  final _eduSchoolController = TextEditingController();
  final _eduDegreeController = TextEditingController();
  final _eduDurationController = TextEditingController();

  final TextEditingController _aiPromptController = TextEditingController();

  // [MỚI] State quản lý hình ảnh
  File? _selectedImageFile; // Ảnh chọn từ máy
  bool _useProfileImage = false; // Checkbox dùng ảnh profile

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Tự động điền thông tin từ User Profile nếu có
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userVM = Provider.of<ProfileViewModel>(context, listen: false);
      if(userVM.user != null) {
        _nameController.text = userVM.user!.fullName;
        _emailController.text = userVM.user!.email;
        if(userVM.user!.phone != null) _phoneController.text = userVM.user!.phone!;
        if(userVM.user!.city != null) _addressController.text = userVM.user!.city!;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _jobTitleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _summaryController.dispose();
    _skillController.dispose();
    _expCompanyController.dispose();
    _expJobController.dispose();
    _expDurationController.dispose();
    _expDescController.dispose();
    _eduSchoolController.dispose();
    _eduDegreeController.dispose();
    _eduDurationController.dispose();
    _aiPromptController.dispose();
    super.dispose();
  }

  // [MỚI] Hàm mở thư viện chọn ảnh
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImageFile = File(image.path);
        _useProfileImage = false; // Tắt chế độ dùng ảnh profile nếu chọn ảnh mới
      });
    }
  }

  void _submitTemplate(CvGenerationViewModel viewModel) async {
    // Xác định nguồn ảnh (URL profile hoặc File đã chọn)
    String? profileAvatarUrl;
    if (_useProfileImage) {
      final userVM = Provider.of<ProfileViewModel>(context, listen: false);
      profileAvatarUrl = userVM.user?.avatarUrl;
    }

    Map<String, dynamic> cvData = {
      "fullName": _nameController.text.trim(),
      "jobTitle": _jobTitleController.text.trim(),
      "email": _emailController.text.trim(),
      "phone": _phoneController.text.trim(),
      "address": _addressController.text.trim(),
      "summary": _summaryController.text.trim(),

      "skills": _skillController.text.isNotEmpty
          ? _skillController.text.split(',').map((e) => {"name": e.trim()}).toList()
          : [],

      "experiences": [
        if (_expCompanyController.text.isNotEmpty)
          {
            "jobTitle": _expJobController.text,
            "company": _expCompanyController.text,
            "duration": _expDurationController.text,
            "description": _expDescController.text,
          }
      ],

      "educations": [
        if (_eduSchoolController.text.isNotEmpty)
          {
            "school": _eduSchoolController.text,
            "degree": _eduDegreeController.text,
            "duration": _eduDurationController.text,
          }
      ]
    };

    // Gọi ViewModel, truyền thêm file ảnh hoặc URL
    File? pdfFile = await viewModel.generateCvFromTemplate(
      _selectedTemplateId,
      cvData,
      localImageFile: _selectedImageFile,
      onlineImageUrl: profileAvatarUrl,
    );

    if (pdfFile != null) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CvPreviewScreen(localPath: pdfFile.path)),
      );
    } else if (viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: ${viewModel.errorMessage}"), backgroundColor: Colors.redAccent),
      );
    }
  }

  // --- UI WIDGETS ---

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool required = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: required ? "$label (*)" : label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 2),
              borderRadius: BorderRadius.circular(10)
          ),
        ),
        validator: required ? (val) => (val == null || val.isEmpty) ? "Vui lòng nhập thông tin này" : null : null,
      ),
    );
  }

  Widget _buildTemplateOption(int id, String name, Color color) {
    bool isSelected = _selectedTemplateId == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedTemplateId = id),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 150,
        height: 200,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          border: isSelected ? Border.all(color: AppColors.primary, width: 3) : null,
          boxShadow: isSelected ? [BoxShadow(color: AppColors.accent.withOpacity(0.4), blurRadius: 10, spreadRadius: 2)] : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 60, color: Colors.black54),
            SizedBox(height: 10),
            Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (isSelected) Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Icon(Icons.check_circle, color: Colors.green, size: 30),
            )
          ],
        ),
      ),
    );
  }

  List<Step> _getSteps(CvGenerationViewModel viewModel) {
    return [
      Step(
        title: Text("Chọn Mẫu"),
        content: Column(
          children: [
            Text("Chọn mẫu thiết kế phù hợp", style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTemplateOption(1, "Modern", Colors.blue[50]!),
                _buildTemplateOption(2, "Classic", Colors.grey[200]!),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTemplateOption(3, "Professional", Colors.indigo[50]!),
                _buildTemplateOption(4, "Creative", Colors.teal[50]!),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.editing,
      ),
      Step(
        title: Text("Thông tin"),
        content: Form(
          key: _personalInfoKey,
          child: Column(
            children: [
              // [MỚI] Widget Chọn Ảnh Đại Diện
              Container(
                margin: EdgeInsets.only(bottom: 20),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Row(
                  children: [
                    // Preview ảnh
                    Container(
                      width: 70, height: 70,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                          image: _selectedImageFile != null
                              ? DecorationImage(image: FileImage(_selectedImageFile!), fit: BoxFit.cover)
                              : (_useProfileImage
                              ? DecorationImage(image: NetworkImage(Provider.of<ProfileViewModel>(context).user?.avatarUrl ?? ""), fit: BoxFit.cover)
                              : null)
                      ),
                      child: (_selectedImageFile == null && !_useProfileImage)
                          ? Icon(Icons.person, size: 40, color: Colors.grey)
                          : null,
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Ảnh đại diện (Tùy chọn)", style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: _pickImage,
                                icon: Icon(Icons.photo_library, size: 16),
                                label: Text("Thư viện"),
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                              ),
                              SizedBox(width: 15),
                              // Nút Checkbox dùng ảnh profile
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _useProfileImage = !_useProfileImage;
                                    if(_useProfileImage) _selectedImageFile = null;
                                  });
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24, height: 24,
                                      child: Checkbox(
                                          value: _useProfileImage,
                                          onChanged: (val) {
                                            setState(() {
                                              _useProfileImage = val!;
                                              if(_useProfileImage) _selectedImageFile = null;
                                            });
                                          }
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Text("Ảnh hồ sơ"),
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),

              _buildTextField(_nameController, "Họ và tên", Icons.person, required: true),
              _buildTextField(_jobTitleController, "Vị trí ứng tuyển", Icons.work, required: true),
              _buildTextField(_emailController, "Email", Icons.email, required: true),
              _buildTextField(_phoneController, "Số điện thoại", Icons.phone, required: true),
              _buildTextField(_addressController, "Địa chỉ", Icons.location_on),
              _buildTextField(_summaryController, "Giới thiệu bản thân", Icons.info_outline, maxLines: 3),
            ],
          ),
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.editing,
      ),
      Step(
        title: Text("Chi tiết"),
        content: Form(
          key: _skillsKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Kỹ năng", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              SizedBox(height: 10),
              _buildTextField(_skillController, "Kỹ năng (cách nhau dấu phẩy)", Icons.star),

              Divider(color: AppColors.primary),

              Text("Học Vấn & Bằng Cấp", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8)
                ),
                child: Column(
                  children: [
                    _buildTextField(_eduSchoolController, "Trường học / Tổ chức", Icons.school),
                    _buildTextField(_eduDegreeController, "Bằng cấp / Chuyên ngành", Icons.book),
                    _buildTextField(_eduDurationController, "Niên khóa (VD: 2018 - 2022)", Icons.date_range),
                  ],
                ),
              ),

              Divider(color: AppColors.primary),

              Text("Kinh nghiệm làm việc", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8)
                ),
                child: Column(
                  children: [
                    _buildTextField(_expCompanyController, "Tên công ty", Icons.business),
                    _buildTextField(_expJobController, "Chức vụ", Icons.badge),
                    _buildTextField(_expDurationController, "Thời gian", Icons.access_time),
                    _buildTextField(_expDescController, "Mô tả công việc", Icons.description, maxLines: 2),
                  ],
                ),
              ),
            ],
          ),
        ),
        isActive: _currentStep >= 2,
        state: _currentStep == 2 ? StepState.editing : StepState.indexed,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CvGenerationViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Tạo CV Chuyên Nghiệp"),
          backgroundColor: AppColors.primary,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.accent,
            tabs: [
              Tab(text: "Mẫu Có Sẵn", icon: Icon(Icons.dashboard_customize)),
              Tab(text: "Gemini AI", icon: Icon(Icons.auto_awesome)),
            ],
          ),
        ),
        body: Consumer<CvGenerationViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            return TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: STEPPER
                Theme(
                  data: ThemeData(
                    colorScheme: ColorScheme.light(primary: AppColors.primary),
                  ),
                  child: Stepper(
                    type: StepperType.horizontal,
                    currentStep: _currentStep,
                    onStepContinue: () {
                      if (_currentStep == 0) setState(() => _currentStep++);
                      else if (_currentStep == 1) {
                        if (_personalInfoKey.currentState!.validate()) setState(() => _currentStep++);
                      } else if (_currentStep == 2) {
                        if (_skillsKey.currentState!.validate()) _submitTemplate(viewModel);
                      }
                    },
                    onStepCancel: () {
                      if (_currentStep > 0) setState(() => _currentStep--);
                    },
                    controlsBuilder: (context, details) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: details.onStepContinue,
                                child: Text(_currentStep == 2 ? "XUẤT PDF & LƯU" : "TIẾP THEO"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _currentStep == 2 ? Colors.green : AppColors.primary,
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            if (_currentStep > 0)
                              OutlinedButton(
                                onPressed: details.onStepCancel,
                                child: Text("QUAY LẠI", style: TextStyle(color: AppColors.primary)),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  side: BorderSide(color: AppColors.primary),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                    steps: _getSteps(viewModel),
                  ),
                ),

                // TAB 2: GEMINI PROMPT (Giữ nguyên)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.deepPurple[50], borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            Icon(Icons.lightbulb, color: Colors.orange),
                            SizedBox(width: 10),
                            Expanded(child: Text("Mẹo: Hãy mô tả chi tiết kinh nghiệm, kỹ năng và trường học của bạn.")),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _aiPromptController,
                        maxLines: 8,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Ví dụ: Tôi là Nguyễn Văn A, tốt nghiệp ĐH Bách Khoa... Kỹ năng: Dart, Firebase...",
                            labelText: "Mô tả về bạn"
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            File? f = await viewModel.generateCvByAi(_aiPromptController.text.trim());
                            if (f != null) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => CvPreviewScreen(localPath: f.path)));
                            } else if (viewModel.errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
                            }
                          },
                          icon: Icon(Icons.auto_awesome),
                          label: Text("TẠO CV VỚI AI"),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: AppColors.primary,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}