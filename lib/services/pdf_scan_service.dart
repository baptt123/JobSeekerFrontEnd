import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

class PdfScanService {
  /// Yêu cầu người dùng chọn một file PDF
  Future<File?> pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) {
      return null;
    }
    return File(result.files.single.path!);
  }

  /// Trích xuất văn bản từ file PDF
  Future<String> extractTextFromPdf(File pdfFile) async {
    final pdfDoc = await PdfDocument.openFile(pdfFile.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final buffer = StringBuffer();

    try {
      // Lặp qua từng trang, render ảnh và scan
      for (int i = 1; i <= pdfDoc.pagesCount; i++) {
        final page = await pdfDoc.getPage(i);

        final imageFile = await _renderPageAsImage(page, i);
        if (imageFile == null) continue;

        final inputImage = InputImage.fromFile(imageFile);
        final recognizedText = await textRecognizer.processImage(inputImage);
        buffer.writeln(recognizedText.text);

        await page.close();
        await imageFile.delete(); // Xóa file ảnh tạm sau khi xử lý
      }
    } catch (e) {
      // Xử lý lỗi nếu có
      rethrow; // Ném lỗi ra để ViewModel bắt
    } finally {
      // Đảm bảo đóng các tài nguyên
      await textRecognizer.close();
      await pdfDoc.close();
    }

    return buffer.toString();
  }

  /// Hàm hỗ trợ: render 1 trang PDF thành file ảnh tạm
  Future<File?> _renderPageAsImage(PdfPage page, int index) async {
    final image = await page.render(
      width: page.width * 2, // Tăng chất lượng ảnh để nhận diện tốt hơn
      height: page.height * 2,
      format: PdfPageImageFormat.png,
    );

    if (image == null) return null;

    final tempDir = await getTemporaryDirectory();
    final imageFile = File("${tempDir.path}/pdf_page_${index}_${DateTime.now().millisecondsSinceEpoch}.png");
    await imageFile.writeAsBytes(image.bytes);
    return imageFile;
  }
}