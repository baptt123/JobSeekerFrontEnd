import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

import '../../../services/pdf_template_builder_service.dart';
import '../../../view_models/user/ai_cv_creator_view_model.dart';
import '../../../view_models/user/theme_view_model.dart';
import '../../../dto/education_dto.dart';
import '../../../dto/project_dto.dart';
import '../../../dto/achievement_dto.dart';
import '../../../utils/app_colors.dart';

class AiCvCreationScreen extends StatelessWidget {
  const AiCvCreationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AiCvCreatorViewModel(),
      child: const _AiCvCreationBody(),
    );
  }
}

class _AiCvCreationBody extends StatefulWidget {
  const _AiCvCreationBody({Key? key}) : super(key: key);

  @override
  State<_AiCvCreationBody> createState() => _AiCvCreationBodyState();
}

class _AiCvCreationBodyState extends State<_AiCvCreationBody> with SingleTickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();
  final PdfTemplateBuilderService _pdfBuilder = PdfTemplateBuilderService();
  late TabController _tabController;

  final _nameCtrl = TextEditingController();
  final _jobCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _syncDataToControllers(AiCvCreatorViewModel vm) {
    if (_nameCtrl.text != vm.cvData.fullName) _nameCtrl.text = vm.cvData.fullName;
    if (_jobCtrl.text != vm.cvData.jobTitle) _jobCtrl.text = vm.cvData.jobTitle;
    if (_emailCtrl.text != vm.cvData.email) _emailCtrl.text = vm.cvData.email;
    if (_phoneCtrl.text != vm.cvData.phone) _phoneCtrl.text = vm.cvData.phone;
    if (_addrCtrl.text != vm.cvData.address) _addrCtrl.text = vm.cvData.address;
    if (_summaryCtrl.text != vm.cvData.summary) _summaryCtrl.text = vm.cvData.summary;
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AiCvCreatorViewModel>(context);
    final themeVm = Provider.of<ThemeViewModel>(context);

    if (vm.cvData.fullName.isNotEmpty && _nameCtrl.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncDataToControllers(vm);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tạo CV (AI & Thủ công)"),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: "Lưu PDF",
            onPressed: () async {
              // Xử lý ảnh trước khi build PDF
              Uint8List? imageBytes;
              if (vm.localImage != null) {
                imageBytes = await vm.localImage!.readAsBytes();
              }

              final pdfBytes = await _pdfBuilder.buildPdf(
                  vm.cvData,
                  templateId: vm.selectedTemplate,
                  avatarBytes: imageBytes // Truyền ảnh vào builder
              );
              await Printing.layoutPdf(onLayout: (_) => pdfBytes);
            },
          )
        ],
      ),
      body: Column(
        children: [
          // --- AI SECTION ---
          ExpansionTile(
            title: const Text("Tạo nhanh với AI (Gemini)",
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _promptController,
                      decoration: const InputDecoration(
                          hintText: "VD: Tôi là Nguyễn Văn A, Flutter Dev 2 năm kinh nghiệm...",
                          border: OutlineInputBorder(),
                          labelText: "Mô tả bản thân"
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.auto_awesome),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        onPressed: vm.isLoading ? null : () async {
                          FocusScope.of(context).unfocus();
                          await vm.generateFromPrompt(_promptController.text);
                          if (vm.errorMessage == null) {
                            _syncDataToControllers(vm);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã tạo nội dung từ AI!")));
                          }
                        },
                        label: vm.isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Tạo nội dung tự động", style: TextStyle(color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
              if (vm.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(vm.errorMessage!, style: const TextStyle(color: Colors.red)),
                )
            ],
          ),

          const Divider(height: 1, thickness: 1),

          // --- TABS ---
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(icon: Icon(Icons.edit_note), text: "Chỉnh sửa"),
              Tab(icon: Icon(Icons.remove_red_eye), text: "Xem trước"),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: FORM EDITOR
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Phần Ảnh Đại Diện (MỚI) ---
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: vm.localImage != null
                                  ? FileImage(vm.localImage!)
                                  : (vm.cvData.avatarUrl != null && vm.cvData.avatarUrl!.isNotEmpty)
                                  ? NetworkImage(vm.cvData.avatarUrl!) as ImageProvider
                                  : null,
                              child: (vm.localImage == null && (vm.cvData.avatarUrl == null || vm.cvData.avatarUrl!.isEmpty))
                                  ? const Icon(Icons.person, size: 50, color: Colors.grey)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: InkWell(
                                onTap: vm.pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text("Thông tin cá nhân", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(height: 10),
                      _buildTextField("Họ và tên", _nameCtrl, (val) => vm.updateField(fullName: val)),
                      _buildTextField("Vị trí ứng tuyển", _jobCtrl, (val) => vm.updateField(jobTitle: val)),
                      _buildTextField("Email", _emailCtrl, (val) => vm.updateField(email: val)),
                      _buildTextField("Số điện thoại", _phoneCtrl, (val) => vm.updateField(phone: val)),
                      _buildTextField("Địa chỉ", _addrCtrl, (val) => vm.updateField(address: val)),
                      _buildTextField("Tóm tắt bản thân", _summaryCtrl, (val) => vm.updateField(summary: val), maxLines: 3),

                      const SizedBox(height: 20),

                      // --- Phần Học Vấn ---
                      _buildSectionHeader(context, "Học vấn", () => _showAddEducationDialog(context, vm)),
                      ...vm.cvData.educations.asMap().entries.map((entry) {
                        final edu = entry.value;
                        return _buildListItem(
                          title: edu.school,
                          subtitle: "${edu.degree} • ${edu.duration}",
                          onDelete: () => vm.removeEducation(entry.key),
                          icon: Icons.school,
                        );
                      }).toList(),

                      const SizedBox(height: 20),

                      // --- Phần Dự Án (MỚI) ---
                      _buildSectionHeader(context, "Dự án cá nhân", () => _showAddProjectDialog(context, vm)),
                      if (vm.cvData.projects.isEmpty) const Text("Chưa có dự án.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                      ...vm.cvData.projects.asMap().entries.map((entry) {
                        final prj = entry.value;
                        return _buildListItem(
                          title: prj.name,
                          subtitle: "${prj.role} • ${prj.link}",
                          onDelete: () => vm.removeProject(entry.key),
                          icon: Icons.folder,
                        );
                      }).toList(),

                      const SizedBox(height: 20),

                      // --- Phần Thành Tích (MỚI) ---
                      _buildSectionHeader(context, "Thành tích", () => _showAddAchievementDialog(context, vm)),
                      if (vm.cvData.achievements.isEmpty) const Text("Chưa có thành tích.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                      ...vm.cvData.achievements.asMap().entries.map((entry) {
                        final ach = entry.value;
                        return _buildListItem(
                          title: ach.name,
                          subtitle: ach.description,
                          onDelete: () => vm.removeAchievement(entry.key),
                          icon: Icons.emoji_events,
                        );
                      }).toList(),

                      const SizedBox(height: 20),

                      // --- Phần Kỹ Năng ---
                      const Text("Kỹ năng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: [
                          ...vm.cvData.skills.asMap().entries.map((e) => Chip(
                            label: Text(e.value.name),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () => vm.removeSkill(e.key),
                          )),
                          ActionChip(
                            label: const Text("Thêm..."),
                            avatar: const Icon(Icons.add),
                            onPressed: () => _showAddSkillDialog(context, vm),
                          )
                        ],
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),

                // TAB 2: PREVIEW
                Column(
                  children: [
                    Container(
                      height: 60,
                      color: themeVm.isDarkMode ? Colors.black26 : Colors.grey[100],
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        children: [
                          _buildTemplateOption(vm, 'modern', "Hiện đại", Colors.blue),
                          _buildTemplateOption(vm, 'classic', "Cổ điển", Colors.black),
                          _buildTemplateOption(vm, 'professional', "Chuyên nghiệp", AppColors.primary),
                          _buildTemplateOption(vm, 'creative', "Sáng tạo", Colors.teal),
                        ],
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder<Uint8List>(
                        // Load ảnh bytes để render preview
                          future: vm.localImage != null ? vm.localImage!.readAsBytes() : Future.value(Uint8List(0)),
                          builder: (context, snapshot) {
                            return PdfPreview(
                              build: (format) => _pdfBuilder.buildPdf(
                                  vm.cvData,
                                  templateId: vm.selectedTemplate,
                                  avatarBytes: (snapshot.hasData && snapshot.data!.isNotEmpty) ? snapshot.data : null
                              ),
                              loadingWidget: const Center(child: CircularProgressIndicator()),
                              useActions: false,
                              initialPageFormat: PdfPageFormat.a4,
                            );
                          }
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
        IconButton(onPressed: onAdd, icon: const Icon(Icons.add_circle, color: AppColors.primary))
      ],
    );
  }

  Widget _buildListItem({required String title, required String subtitle, required VoidCallback onDelete, required IconData icon}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onDelete),
      ),
    );
  }

  Widget _buildTemplateOption(AiCvCreatorViewModel vm, String id, String name, Color color) {
    bool isSelected = vm.selectedTemplate == id;
    return GestureDetector(
      onTap: () => vm.changeTemplate(id),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Center(
            child: Text(name, style: TextStyle(color: isSelected ? Colors.white : color, fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, Function(String) onChanged, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        onChanged: onChanged,
      ),
    );
  }

  // --- Dialogs ---

  void _showAddSkillDialog(BuildContext context, AiCvCreatorViewModel vm) {
    String newSkill = "";
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text("Thêm kỹ năng"),
      content: TextField(autofocus: true, decoration: const InputDecoration(hintText: "VD: Flutter..."), onChanged: (v) => newSkill = v),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
        TextButton(onPressed: () { if(newSkill.isNotEmpty) vm.addSkill(newSkill); Navigator.pop(context); }, child: const Text("Thêm")),
      ],
    ));
  }

  void _showAddEducationDialog(BuildContext context, AiCvCreatorViewModel vm) {
    String school = "", degree = "", duration = "";
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text("Thêm Học vấn"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(decoration: const InputDecoration(labelText: "Trường"), onChanged: (v) => school = v),
        TextField(decoration: const InputDecoration(labelText: "Bằng cấp"), onChanged: (v) => degree = v),
        TextField(decoration: const InputDecoration(labelText: "Niên khóa"), onChanged: (v) => duration = v),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
        TextButton(onPressed: () {
          if(school.isNotEmpty) vm.addEducation(EducationDto(school: school, degree: degree, duration: duration));
          Navigator.pop(context);
        }, child: const Text("Lưu")),
      ],
    ));
  }

  // Dialog Dự án (MỚI)
  void _showAddProjectDialog(BuildContext context, AiCvCreatorViewModel vm) {
    String name = "", role = "", link = "", desc = "";
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text("Thêm Dự án"),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(decoration: const InputDecoration(labelText: "Tên dự án"), onChanged: (v) => name = v),
          TextField(decoration: const InputDecoration(labelText: "Vai trò"), onChanged: (v) => role = v),
          TextField(decoration: const InputDecoration(labelText: "Link (Git/Demo)"), onChanged: (v) => link = v),
          TextField(decoration: const InputDecoration(labelText: "Mô tả ngắn"), maxLines: 2, onChanged: (v) => desc = v),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
        TextButton(onPressed: () {
          if(name.isNotEmpty) vm.addProject(ProjectDto(name: name, role: role, link: link, description: desc));
          Navigator.pop(context);
        }, child: const Text("Lưu")),
      ],
    ));
  }

  // Dialog Thành tích (MỚI)
  void _showAddAchievementDialog(BuildContext context, AiCvCreatorViewModel vm) {
    String name = "", desc = "";
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text("Thêm Thành tích"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(decoration: const InputDecoration(labelText: "Tên giải thưởng/Thành tích"), onChanged: (v) => name = v),
        TextField(decoration: const InputDecoration(labelText: "Mô tả chi tiết"), maxLines: 2, onChanged: (v) => desc = v),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
        TextButton(onPressed: () {
          if(name.isNotEmpty) vm.addAchievement(AchievementDto(name: name, description: desc));
          Navigator.pop(context);
        }, child: const Text("Lưu")),
      ],
    ));
  }
}