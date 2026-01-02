import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

import '../../../services/pdf_template_builder_service.dart';
import '../../../view_models/user/ai_cv_creator_view_model.dart';

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
    if (_summaryCtrl.text != vm.cvData.summary) _summaryCtrl.text = vm.cvData.summary;
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AiCvCreatorViewModel>(context);

    if (vm.cvData.fullName.isNotEmpty && _nameCtrl.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncDataToControllers(vm);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tạo CV AI & Template"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final pdfBytes = await _pdfBuilder.buildPdf(vm.cvData, templateId: vm.selectedTemplate);
              await Printing.layoutPdf(onLayout: (_) => pdfBytes);
            },
          )
        ],
      ),
      body: Column(
        children: [
          ExpansionTile(
            title: const Text("Bước 1: AI tạo nội dung"),
            initiallyExpanded: vm.cvData.fullName.isEmpty,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promptController,
                        decoration: const InputDecoration(
                          hintText: "Mô tả: Tôi là Nam, Dev 3 năm...",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: vm.isLoading ? null : () async {
                        FocusScope.of(context).unfocus();
                        await vm.generateFromPrompt(_promptController.text);
                        if (vm.errorMessage == null) {
                          _tabController.animateTo(0);
                        }
                      },
                      child: vm.isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("AI Create"),
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

          const Divider(height: 1, thickness: 2),

          TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(icon: Icon(Icons.edit), text: "Chỉnh sửa"),
              Tab(icon: Icon(Icons.style), text: "Chọn Mẫu (Preview)"),
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
                    children: [
                      _buildTextField("Họ và tên", _nameCtrl, (val) => vm.updateField(fullName: val)),
                      _buildTextField("Vị trí", _jobCtrl, (val) => vm.updateField(jobTitle: val)),
                      _buildTextField("Email", _emailCtrl, (val) => vm.updateField(email: val)),
                      _buildTextField("Tóm tắt", _summaryCtrl, (val) => vm.updateField(summary: val), maxLines: 3),
                      const SizedBox(height: 10),
                      const Text("Kỹ năng (thêm nhanh):"),
                      Wrap(
                        spacing: 8,
                        children: vm.cvData.skills.map((s) => Chip(label: Text(s.name))).toList(),
                      ),
                      TextButton.icon(
                          onPressed: () => _showAddSkillDialog(context, vm),
                          icon: const Icon(Icons.add),
                          label: const Text("Thêm kỹ năng")
                      )
                    ],
                  ),
                ),

                // TAB 2: PDF PREVIEW & TEMPLATE SELECTOR
                Column(
                  children: [
                    // Thanh chọn Template
                    Container(
                      height: 60,
                      color: Colors.grey[200],
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        children: [
                          _buildTemplateOption(vm, 'modern', "Hiện đại", Colors.blue),
                          _buildTemplateOption(vm, 'classic', "Cổ điển", Colors.black),
                          _buildTemplateOption(vm, 'professional', "Pro", Colors.indigo),
                          _buildTemplateOption(vm, 'creative', "Sáng tạo", Colors.teal),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PdfPreview(
                        // Truyền templateId từ ViewModel vào
                        build: (format) => _pdfBuilder.buildPdf(vm.cvData, templateId: vm.selectedTemplate),
                        loadingWidget: const Center(child: CircularProgressIndicator()),
                        useActions: false,
                        initialPageFormat: PdfPageFormat.a4,
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

  Widget _buildTemplateOption(AiCvCreatorViewModel vm, String id, String name, Color color) {
    bool isSelected = vm.selectedTemplate == id;
    return GestureDetector(
      onTap: () => vm.changeTemplate(id),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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

  void _showAddSkillDialog(BuildContext context, AiCvCreatorViewModel vm) {
    String newSkill = "";
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text("Thêm kỹ năng"),
      content: TextField(onChanged: (v) => newSkill = v),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
        TextButton(onPressed: () {
          if(newSkill.isNotEmpty) vm.addSkill(newSkill);
          Navigator.pop(context);
        }, child: const Text("Thêm")),
      ],
    ));
  }
}