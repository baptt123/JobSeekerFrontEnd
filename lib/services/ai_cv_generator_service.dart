import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../dto/create_cv_dto.dart';
import '../dto/education_dto.dart';
import '../dto/experience_dto.dart';
import '../dto/skill_dto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiCvGeneratorService {
  // Singleton
  static final AiCvGeneratorService _instance = AiCvGeneratorService._internal();
  factory AiCvGeneratorService() => _instance;
  AiCvGeneratorService._internal();

  GenerativeModel? _model;

  // Hàm khởi tạo model (gọi mỗi khi dùng để đảm bảo lấy key mới nhất nếu có reload)
  void _initModel() {
    // Lấy Key từ file .env
    final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY chưa được cấu hình trong file .env');
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.7,
      ),
    );
  }

  Future<CreateCvDto> generateCvFromPrompt(String userPrompt) async {
    // Đảm bảo model đã được khởi tạo
    if (_model == null) _initModel();

    final promptText = '''
    Bạn là chuyên gia tạo CV. Hãy tạo một CV chuyên nghiệp dựa trên mô tả sau: "$userPrompt".
    Yêu cầu quan trọng:
    1. Trả về định dạng JSON thuần túy.
    2. Tuyệt đối KHÔNG bọc trong markdown (như ```json ... ```).
    3. Cấu trúc JSON:
    {
      "fullName": "String",
      "email": "String",
      "phone": "String",
      "summary": "String",
      "experiences": [ { "jobTitle": "", "company": "", "description": "" } ],
      "skills": [ { "name": "" } ]
    }
    ''';

    try {
      final content = [Content.text(promptText)];
      final response = await _model!.generateContent(content);

      if (response.text == null) throw Exception("AI không trả về dữ liệu");

      // Clean JSON string
      String cleanJson = response.text!
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final Map<String, dynamic> data = jsonDecode(cleanJson);

      return CreateCvDto(
        fullName: data['fullName'] ?? "",
        jobTitle: data['jobTitle'] ?? "N/A",
        email: data['email'] ?? "",
        phone: data['phone'] ?? "",
        address: data['address'] ?? "",
        summary: data['summary'] ?? "",
        experiences: (data['experiences'] as List? ?? []).map((e) => ExperienceDto(
          jobTitle: e['jobTitle'] ?? "",
          company: e['company'] ?? "",
          duration: e['duration'] ?? "",
          description: e['description'] ?? "",
        )).toList(),
        educations: (data['educations'] as List? ?? []).map((e) => EducationDto(
          school: e['school'] ?? "",
          degree: e['degree'] ?? "",
          duration: e['duration'] ?? "",
        )).toList(),
        skills: (data['skills'] as List? ?? []).map((e) => SkillDto(
          name: e['name'] ?? "",
        )).toList(),
      );
    } catch (e) {
      print("Error generating CV with Gemini: $e");
      // Ném lỗi rõ ràng hơn để UI hiển thị
      if (e.toString().contains("API_KEY_INVALID") || e.toString().contains("leaked")) {
        throw Exception("API Key bị lỗi hoặc hết hạn. Vui lòng kiểm tra file .env");
      }
      throw Exception("Lỗi tạo CV: ${e.toString()}");
    }
  }
}