import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;

enum UploadCVStatus { init, uploaded, uploading, success, error }

class UploadCVViewModel extends ChangeNotifier {
  UploadCVStatus _status = UploadCVStatus.init;
  UploadCVStatus get status => _status;

  String? fileName;
  File? file;
  List<String> keywords = [];
  String? cloudUrl; // url CV sau khi backend đẩy lên Cloudinary

  void selectFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      file = File(result.files.single.path!);
      fileName = result.files.single.name;
      _status = UploadCVStatus.uploaded;
      notifyListeners();
    }
  }

  void removeFile() {
    file = null;
    fileName = null;
    keywords.clear();
    cloudUrl = null;
    _status = UploadCVStatus.init;
    notifyListeners();
  }

  Future<void> submit({required String token}) async {
    if (file == null) return;

    _status = UploadCVStatus.uploading;
    notifyListeners();

    try {
      // OCR nếu là ảnh
      String extractedText = "";
      if (fileName!.toLowerCase().endsWith(".png") ||
          fileName!.toLowerCase().endsWith(".jpg") ||
          fileName!.toLowerCase().endsWith(".jpeg")) {
        final inputImage = InputImage.fromFile(file!);
        final textRecognizer = TextRecognizer();
        final recognizedText = await textRecognizer.processImage(inputImage);
        textRecognizer.close();
        extractedText = recognizedText.text;
        keywords = _extractKeywords(extractedText);
      }

      // Upload multipart request
      final uri = Uri.parse("http://localhost:3000/cv/upload");
      var request = http.MultipartRequest("POST", uri)
        ..files.add(await http.MultipartFile.fromPath("file", file!.path))
        ..fields["title"] = fileName ?? ""
        ..fields["content"] = extractedText
        ..fields["keywords"] = jsonEncode(keywords);

      // Thêm Authorization nếu có
      request.headers['Authorization'] = 'Bearer $token';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        cloudUrl = data["file_url"]; // backend trả về url từ Cloudinary
        _status = UploadCVStatus.success;
      } else {
        _status = UploadCVStatus.error;
      }
    } catch (e) {
      _status = UploadCVStatus.error;
    }

    notifyListeners();
  }

  List<String> _extractKeywords(String text) {
    final words = text.split(RegExp(r"\s+"));
    final stopwords = {"the", "is", "and", "a", "an", "to", "of", "in"};
    final freq = <String, int>{};

    for (var w in words) {
      final word = w.toLowerCase().replaceAll(RegExp(r"[^a-z]"), "");
      if (word.isNotEmpty && !stopwords.contains(word)) {
        freq[word] = (freq[word] ?? 0) + 1;
      }
    }

    final sorted = freq.keys.toList()
      ..sort((a, b) => freq[b]!.compareTo(freq[a]!));
    return sorted.take(10).toList();
  }

  void reset() {
    fileName = null;
    file = null;
    keywords.clear();
    cloudUrl = null;
    _status = UploadCVStatus.init;
    notifyListeners();
  }
}
