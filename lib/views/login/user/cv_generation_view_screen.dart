import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../view_models/user/cv_generation_view_model.dart';
import 'cv_preview_screen.dart';

class CvGenerationViewScreen extends StatefulWidget {
  @override
  _CvGenerationViewScreenState createState() => _CvGenerationViewScreenState();
}

class _CvGenerationViewScreenState extends State<CvGenerationViewScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // State cho Stepper Template
  int _currentStep = 0;
  int _selectedTemplateId = 1;

  // Form Keys để validation
  final _personalInfoKey = GlobalKey<FormState>();
  final _skillsKey = GlobalKey<FormState>();

  // Controllers cho Template
  final _nameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _summaryController = TextEditingController();

  final _skillController = TextEditingController(); // Nhập chuỗi

  // Demo 1 Experience
  final _expCompanyController = TextEditingController();
  final _expJobController = TextEditingController();
  final _expDurationController = TextEditingController();
  final _expDescController = TextEditingController();

  // Demo 1 Education
  final _eduSchoolController = TextEditingController();
  final _eduDegreeController = TextEditingController();
  final _eduDurationController = TextEditingController();

  // Controller cho AI Tab
  final TextEditingController _aiPromptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

  // --- LOGIC GỬI DỮ LIỆU ---
  void _submitTemplate(CvGenerationViewModel viewModel) async {
    // Thu thập dữ liệu
    Map<String, dynamic> cvData = {
      "fullName": _nameController.text.trim(),
      "jobTitle": _jobTitleController.text.trim(),
      "email": _emailController.text.trim(),
      "phone": _phoneController.text.trim(),
      "address": _addressController.text.trim(),
      "summary": _summaryController.text.trim(),

      // Chuyển string skills thành mảng object
      "skills": _skillController.text.isNotEmpty
          ? _skillController.text.split(',').map((e) => {"name": e.trim()}).toList()
          : [],

      // Đóng gói mảng experience (Demo 1 item)
      "experiences": [
        if (_expCompanyController.text.isNotEmpty)
          {
            "jobTitle": _expJobController.text,
            "company": _expCompanyController.text,
            "duration": _expDurationController.text,
            "description": _expDescController.text,
          }
      ],

      // Đóng gói mảng education (Demo 1 item)
      "educations": [
        if (_eduSchoolController.text.isNotEmpty)
          {
            "school": _eduSchoolController.text,
            "degree": _eduDegreeController.text,
            "duration": _eduDurationController.text,
          }
      ]
    };

    File? pdfFile = await viewModel.generateCvFromTemplate(_selectedTemplateId, cvData);

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

  // --- WIDGETS ---

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool required = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: required ? "$label (*)" : label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[50],
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
          border: isSelected ? Border.all(color: Colors.blue[800]!, width: 3) : null,
          boxShadow: isSelected ? [BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 10, spreadRadius: 2)] : [],
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
            Text("Chọn mẫu thiết kế phù hợp với bạn", style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTemplateOption(1, "Truyền thống", Colors.blue[100]!),
                _buildTemplateOption(2, "Hiện đại", Colors.purple[100]!),
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
              Text("Kỹ năng", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              SizedBox(height: 10),
              _buildTextField(_skillController, "Kỹ năng (cách nhau dấu phẩy)", Icons.star),
              Divider(),
              Text("Kinh nghiệm làm việc", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              SizedBox(height: 10),
              _buildTextField(_expCompanyController, "Tên công ty", Icons.business),
              _buildTextField(_expJobController, "Chức vụ", Icons.badge),
              _buildTextField(_expDurationController, "Thời gian (VD: 2020 - Nay)", Icons.access_time),
              _buildTextField(_expDescController, "Mô tả công việc", Icons.description, maxLines: 2),
              Divider(),
              Text("Học vấn", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              SizedBox(height: 10),
              _buildTextField(_eduSchoolController, "Trường học", Icons.school),
              _buildTextField(_eduDegreeController, "Bằng cấp / Chuyên ngành", Icons.book),
              _buildTextField(_eduDurationController, "Niên khóa", Icons.date_range),
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
        appBar: AppBar(
          title: Text("Tạo CV Chuyên Nghiệp"),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: "Mẫu Có Sẵn", icon: Icon(Icons.dashboard_customize)),
              Tab(text: "Gemini AI", icon: Icon(Icons.auto_awesome)),
            ],
          ),
        ),
        body: Consumer<CvGenerationViewModel>(
          builder: (context, viewModel, child) {
            // Loading Overlay
            if (viewModel.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text("Đang tạo CV, vui lòng chờ...", style: TextStyle(fontSize: 16)),
                  ],
                ),
              );
            }

            return TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: TEMPLATE STEPPER
                Theme(
                  data: ThemeData(
                    colorScheme: ColorScheme.light(primary: Colors.blueAccent),
                  ),
                  child: Stepper(
                    type: StepperType.horizontal,
                    currentStep: _currentStep,
                    onStepContinue: () {
                      if (_currentStep == 0) {
                        setState(() => _currentStep++);
                      } else if (_currentStep == 1) {
                        if (_personalInfoKey.currentState!.validate()) {
                          setState(() => _currentStep++);
                        }
                      } else if (_currentStep == 2) {
                        if (_skillsKey.currentState!.validate()) {
                          _submitTemplate(viewModel);
                        }
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
                                child: Text(_currentStep == 2 ? "XUẤT PDF & XEM TRƯỚC" : "TIẾP THEO"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _currentStep == 2 ? Colors.green : Colors.blueAccent,
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            if (_currentStep > 0)
                              OutlinedButton(
                                onPressed: details.onStepCancel,
                                child: Text("QUAY LẠI"),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 15),
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

                // TAB 2: GEMINI AI (Giữ nguyên)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            Icon(Icons.lightbulb, color: Colors.orange),
                            SizedBox(width: 10),
                            Expanded(child: Text("Mẹo: Hãy mô tả chi tiết kinh nghiệm, kỹ năng của bạn để AI tạo ra CV tốt nhất.")),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _aiPromptController,
                        maxLines: 8,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Ví dụ: Tôi là Nguyễn Văn A, có 3 năm kinh nghiệm Flutter. Kỹ năng: Dart, Firebase...",
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
                            backgroundColor: Colors.deepPurple,
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