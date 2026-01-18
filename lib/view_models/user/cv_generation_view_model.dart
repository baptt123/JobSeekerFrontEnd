import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../../services/cv_service.dart';
import '../../services/pdf_template_builder_service.dart';
import '../../services/ai_cv_generator_service.dart'; // Thêm service AI
import '../../dto/create_cv_dto.dart';

class CvGenerationViewModel extends ChangeNotifier {
  final PdfTemplateBuilderService _pdfBuilder = PdfTemplateBuilderService();
  final AiCvGeneratorService _aiService = AiCvGeneratorService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isAiGenerating = false;
  bool get isAiGenerating => _isAiGenerating;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Helper: Lưu file PDF
  Future<File> _saveBytesToTempFile(List<int> bytes, String prefix) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = '${prefix}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  // Helper: Tải ảnh từ URL
  Future<Uint8List?> _fetchImageBytesFromUrl(String url) async {
    try {
      if (url.isEmpty) return null;
      final response = await Dio().get(url, options: Options(responseType: ResponseType.bytes));
      return Uint8List.fromList(response.data);
    } catch (e) {
      return null;
    }
  }

  // [MỚI] Gọi AI viết mô tả ngắn
  Future<String> generateAiDescription(String contextInfo, String type) async {
    if (contextInfo.isEmpty) return "";
    _isAiGenerating = true;
    notifyListeners();

    String prompt = "";
    if (type == 'exp') prompt = "Viết mô tả ngắn gọn (3 gạch đầu dòng) cho vị trí công việc: $contextInfo. Tiếng Việt chuyên nghiệp.";
    else if (type == 'project') prompt = "Viết mô tả ngắn gọn về dự án: $contextInfo. Nêu công nghệ và chức năng chính. Tiếng Việt.";
    else if (type == 'achievement') prompt = "Viết lại thành tích này cho hay hơn: $contextInfo. Tiếng Việt.";
    else if (type == 'summary') prompt = "Viết đoạn giới thiệu bản thân ngắn gọn cho CV dựa trên vị trí: $contextInfo. Tiếng Việt.";

    try {
      return await _aiService.generateSectionContent(prompt);
    } catch (e) {
      return "Không thể tạo nội dung.";
    } finally {
      _isAiGenerating = false;
      notifyListeners();
    }
  }

  // Tạo CV từ Template
  Future<File?> generateCvFromTemplate(
      int templateId,
      CreateCvDto cvData, // Nhận DTO đầy đủ
          {File? localImageFile, String? onlineImageUrl}
      ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Xử lý ảnh
      Uint8List? avatarBytes;
      if (localImageFile != null) {
        avatarBytes = await localImageFile.readAsBytes();
      } else if (onlineImageUrl != null && onlineImageUrl.isNotEmpty) {
        avatarBytes = await _fetchImageBytesFromUrl(onlineImageUrl);
      }

      String templateName = 'modern';
      switch(templateId) {
        case 1: templateName = 'modern'; break;
        case 2: templateName = 'classic'; break;
        case 3: templateName = 'professional'; break;
        case 4: templateName = 'creative'; break;
      }

      // Gọi Builder (Lưu ý: Bạn cần update PdfTemplateBuilderService để nhận field projects/achievements trong DTO)
      List<int> pdfBytes = await _pdfBuilder.buildPdf(
          cvData,
          templateId: templateName,
          avatarBytes: avatarBytes
      );

      return await _saveBytesToTempFile(pdfBytes, "cv_template_$templateId");
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}