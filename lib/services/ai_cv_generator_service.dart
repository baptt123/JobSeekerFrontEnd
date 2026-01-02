import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../dto/create_cv_dto.dart';
import '../dto/education_dto.dart';
import '../dto/experience_dto.dart';
import '../dto/skill_dto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class AiCvGeneratorService {
  // Singleton pattern
  static final AiCvGeneratorService _instance = AiCvGeneratorService._internal();
  // factory AiCvGeneratorService() => _instance;
  AiCvGeneratorService._internal();

  // ĐIỀN API KEY CỦA BẠN VÀO ĐÂY
  // Lưu ý: Khi release app thật thì nên giấu key này hoặc dùng backend proxy
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  late final GenerativeModel _model;

  AiCvGeneratorService() {
    // Khởi tạo model Gemini qua Google AI SDK (Không dùng Firebase)
    _model = GenerativeModel(
      model: 'gemini-2.5-flash', // Model nhanh và miễn phí
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json', // Ép kiểu trả về JSON
        temperature: 0.7,
      ),
    );
  }

  Future<CreateCvDto> generateCvFromPrompt(String userPrompt) async {
    final promptText = '''
    Bạn là chuyên gia tạo CV. Hãy tạo một CV chuyên nghiệp dựa trên mô tả sau: "$userPrompt".
    
    Yêu cầu quan trọng:
    1. Trả về định dạng JSON thuần túy.
    2. Tuyệt đối KHÔNG bọc trong markdown (như ```json ... ```). Chỉ trả về raw JSON string.
    3. Nếu thiếu thông tin, hãy tự điền nội dung giả định hợp lý (placeholder) để người dùng sửa sau.
    4. Cấu trúc JSON phải khớp chính xác với mẫu sau:
    {
      "fullName": "String",
      "jobTitle": "String",
      "email": "String",
      "phone": "String",
      "address": "String",
      "summary": "String",
      "experiences": [
        { "jobTitle": "", "company": "", "duration": "", "description": "" }
      ],
      "educations": [
        { "school": "", "degree": "", "duration": "" }
      ],
      "skills": [
        { "name": "" }
      ]
    }
    ''';

    try {
      final content = [Content.text(promptText)];
      final response = await _model.generateContent(content);

      if (response.text == null) throw Exception("AI không trả về dữ liệu");

      // Xử lý sạch chuỗi JSON nếu AI lỡ thêm markdown (dù đã nhắc prompt)
      String cleanJson = response.text!
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final Map<String, dynamic> data = jsonDecode(cleanJson);

      return CreateCvDto(
        fullName: data['fullName'] ?? "Your Name",
        jobTitle: data['jobTitle'] ?? "Job Title",
        email: data['email'] ?? "email@example.com",
        phone: data['phone'] ?? "0123456789",
        address: data['address'] ?? "City, Country",
        summary: data['summary'] ?? "Professional summary here...",
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
      // Ném lỗi ra để ViewModel bắt và hiện thông báo
      if (e.toString().contains("API_KEY_INVALID")) {
        throw Exception("API Key không hợp lệ. Vui lòng kiểm tra lại code.");
      }
      throw Exception("Không thể tạo CV. Vui lòng thử lại chi tiết hơn.");
    }
  }
}