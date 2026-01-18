import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../dto/create_cv_dto.dart';
import '../dto/education_dto.dart';
import '../dto/experience_dto.dart';
import '../dto/skill_dto.dart';
import '../dto/project_dto.dart';
import '../dto/achievement_dto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiCvGeneratorService {
  static final AiCvGeneratorService _instance = AiCvGeneratorService._internal();
  factory AiCvGeneratorService() => _instance;
  AiCvGeneratorService._internal();

  GenerativeModel? _model;

  void _initModel() {
    final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) throw Exception('Chưa cấu hình GEMINI_API_KEY');

    _model = GenerativeModel(
      model: 'gemini-2.5-flash', // Hoặc gemini-pro
      apiKey: apiKey,
      generationConfig: GenerationConfig(temperature: 0.7),
    );
  }

  // Hàm: Tạo Full CV từ mô tả văn bản (Logic đầy đủ)
  // Hàm: Tạo Full CV từ mô tả văn bản (Phiên bản "Sáng tạo lấp đầy")
  Future<CreateCvDto> generateCvFromPrompt(String userPrompt) async {
    if (_model == null) _initModel();

    final promptText = '''
    Bạn là một chuyên gia viết CV hàng đầu. Nhiệm vụ của bạn là tạo ra một hồ sơ xin việc (CV) **HOÀN CHỈNH VÀ CHUYÊN NGHIỆP** dựa trên thông tin sơ bộ: "$userPrompt".

    QUY TẮC CỐT LÕI (BẮT BUỘC):
    1. **KHÔNG ĐƯỢC ĐỂ TRỐNG BẤT KỲ TRƯỜNG NÀO**: Nếu người dùng cung cấp ít thông tin, bạn PHẢI **tự sáng tạo** ra nội dung phù hợp, logic và chuyên nghiệp cho vị trí đó.
       - Ví dụ: Nếu họ chỉ nói "Lập trình viên Flutter", bạn hãy tự điền các kỹ năng (Dart, Bloc, Firebase...), tự bịa ra 2 công ty cũ với mô tả công việc chi tiết, tự thêm dự án mẫu và bằng cấp liên quan.
    2. **Thông tin liên hệ giả định**: Nếu thiếu email/sđt/địa chỉ, hãy điền placeholder dạng: "[Email của bạn]", "[Số điện thoại]", "[Địa chỉ]".
    3. **Output**: Chỉ trả về duy nhất chuỗi JSON (không markdown).
    
    Cấu trúc JSON cần trả về:
    {
      "fullName": "Tên người dùng (hoặc 'Ứng viên Tiềm năng' nếu thiếu)",
      "jobTitle": "Vị trí công việc (suy luận từ prompt)",
      "email": "Email",
      "phone": "SĐT",
      "address": "Địa chỉ",
      "summary": "Viết một đoạn tóm tắt chuyên nghiệp (khoảng 3-4 câu) nhấn mạnh vào điểm mạnh và mục tiêu nghề nghiệp phù hợp với vị trí này.",
      "skills": [ 
         { "name": "Kỹ năng 1 (VD: Teamwork)" },
         { "name": "Kỹ năng chuyên môn 1" }
         // Hãy liệt kê ít nhất 5-7 kỹ năng quan trọng
      ],
      "experiences": [
        {
          "jobTitle": "Vị trí (VD: Senior Flutter Dev)",
          "company": "Tên công ty (VD: Công ty Công nghệ A)",
          "duration": "Thời gian (VD: 2021 - Nay)",
          "description": "- Chịu trách nhiệm thiết kế kiến trúc app.\\n- Tối ưu hóa hiệu năng giảm 30% thời gian load.\\n- Quản lý team 5 người." 
        },
        {
          "jobTitle": "Vị trí cũ hơn",
          "company": "Tên công ty (VD: Startup B)",
          "duration": "Thời gian (VD: 2019 - 2021)",
          "description": "- Tham gia phát triển tính năng X.\\n- Fix bugs và bảo trì hệ thống."
        }
      ],
      "educations": [
        {
          "school": "Trường Đại học (VD: Đại học Bách Khoa...)",
          "degree": "Chuyên ngành (VD: Kỹ sư phần mềm)",
          "duration": "2015 - 2019"
        }
      ],
      "projects": [
        {
          "name": "Tên dự án tiêu biểu",
          "role": "Vai trò",
          "description": "Mô tả dự án: Công nghệ sử dụng, chức năng chính và kết quả đạt được.",
          "link": ""
        }
      ],
      "achievements": [
        {
          "name": "Tên thành tích (VD: Nhân viên xuất sắc năm)",
          "description": "Mô tả ngắn gọn"
        }
      ]
    }
    ''';

    try {
      final content = [Content.text(promptText)];
      final response = await _model!.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception("AI không phản hồi.");
      }

      // Xử lý chuỗi JSON (Lọc bỏ markdown ```json ... ```)
      String cleanJson = response.text!.trim();
      final startIndex = cleanJson.indexOf('{');
      final endIndex = cleanJson.lastIndexOf('}');

      if (startIndex != -1 && endIndex != -1) {
        cleanJson = cleanJson.substring(startIndex, endIndex + 1);
      } else {
        throw Exception("Định dạng dữ liệu không hợp lệ.");
      }

      final Map<String, dynamic> data = jsonDecode(cleanJson);

      return CreateCvDto(
        fullName: data['fullName'] ?? "",
        jobTitle: data['jobTitle'] ?? "",
        email: data['email'] ?? "",
        phone: data['phone'] ?? "",
        address: data['address'] ?? "",
        summary: data['summary'] ?? "",
        skills: (data['skills'] as List?)?.map((e) => SkillDto.fromJson(e)).toList() ?? [],
        experiences: (data['experiences'] as List?)?.map((e) => ExperienceDto.fromJson(e)).toList() ?? [],
        educations: (data['educations'] as List?)?.map((e) => EducationDto.fromJson(e)).toList() ?? [],
        projects: (data['projects'] as List?)?.map((e) => ProjectDto.fromJson(e)).toList() ?? [],
        achievements: (data['achievements'] as List?)?.map((e) => AchievementDto.fromJson(e)).toList() ?? [],
      );

    } catch (e) {
      throw Exception("Lỗi tạo CV: ${e.toString()}");
    }
  }

  // [MỚI] Hàm hỗ trợ viết mô tả cho từng phần (Kinh nghiệm, Dự án...)
  // [MỚI] Hàm sinh nội dung ngắn cho description
  Future<String> generateSectionContent(String prompt) async {
    if (_model == null) _initModel();
    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      return response.text?.replaceAll('*', '-').trim() ?? "";
    } catch (e) {
      return "Lỗi AI: $e";
    }
  }
}