import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdfx/pdfx.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

class ScanPdfScreen extends StatefulWidget {
  const ScanPdfScreen({Key? key}) : super(key: key);

  @override
  State<ScanPdfScreen> createState() => _ScanPdfScreenState();
}

class _ScanPdfScreenState extends State<ScanPdfScreen> {
  String extractedText = "";
  bool isLoading = false;

  Future<void> _pickAndScanPdf() async {
    setState(() {
      extractedText = "";
      isLoading = true;
    });

    // 🟢 Chọn file PDF
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) {
      setState(() => isLoading = false);
      return;
    }

    final file = File(result.files.single.path!);
    final pdfDoc = await PdfDocument.openFile(file.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    StringBuffer buffer = StringBuffer();

    // 🟠 Lặp qua từng trang PDF, render thành ảnh, rồi scan bằng ML Kit
    for (int i = 1; i <= pdfDoc.pagesCount; i++) {
      final page = await pdfDoc.getPage(i);

      final imageFile = await _renderPageAsImage(page, i);
      final inputImage = InputImage.fromFile(imageFile);

      final recognizedText = await textRecognizer.processImage(inputImage);
      buffer.writeln(recognizedText.text);

      await page.close();
    }

    await textRecognizer.close();

    setState(() {
      extractedText = buffer.toString();
      isLoading = false;
    });
  }

  Future<File> _renderPageAsImage(PdfPage page, int index) async {
    final image = await page.render(
      width: page.width,
      height: page.height,
      format: PdfPageImageFormat.png,
    );

    final tempDir = await getTemporaryDirectory();
    final imageFile = File("${tempDir.path}/page_$index.png");
    await imageFile.writeAsBytes(image!.bytes);
    return imageFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan nội dung PDF")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: isLoading ? null : _pickAndScanPdf,
              icon: const Icon(Icons.upload_file),
              label: const Text("Chọn file PDF để quét"),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const CircularProgressIndicator()
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    extractedText.isEmpty
                        ? "Chưa có nội dung nào được quét."
                        : extractedText,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
