import 'dart:typed_data'; // Chỉ import Uint8List từ đây
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// Màn hình xem trước PDF
class PdfPreviewScreen extends StatelessWidget {
  final String username;

  const PdfPreviewScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xem trước CV'),
      ),
      body: PdfPreview(
        build: (format) => _generateCv(format, username),
      ),
    );
  }
}

// Hàm tạo PDF, trả về Future<Uint8List>
Future<Uint8List> _generateCv(PdfPageFormat format, String username) async {
  final doc = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

  // Load font chữ từ Google Fonts (cần internet)
  final font = await PdfGoogleFonts.robotoRegular();
  final boldFont = await PdfGoogleFonts.robotoBold();

  doc.addPage(
    pw.Page(
      pageFormat: format,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              color: PdfColors.blueGrey800,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    username,
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 32,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Lập trình viên Flutter',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 18,
                      color: PdfColors.blueGrey50,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Main Content
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Giới thiệu', boldFont),
                  pw.Text(
                    'Là một lập trình viên có kinh nghiệm với mong muốn được làm việc trong một môi trường chuyên nghiệp, năng động để phát triển bản thân và đóng góp vào sự thành công của công ty.',
                    style: pw.TextStyle(font: font, fontSize: 12, lineSpacing: 5),
                  ),
                  pw.SizedBox(height: 20),

                  _buildSectionHeader('Kinh nghiệm làm việc', boldFont),
                  _buildExperienceItem(
                    'Công ty ABC',
                    '2022 - Hiện tại',
                    'Phát triển và bảo trì các ứng dụng di động cho cả iOS và Android bằng Flutter. Tối ưu hiệu năng và trải nghiệm người dùng.',
                    font,
                    boldFont,
                  ),
                  _buildExperienceItem(
                    'Công ty XYZ',
                    '2020 - 2022',
                    'Tham gia vào các dự án outsourcing, làm việc với các framework khác nhau. Hỗ trợ phân tích yêu cầu của khách hàng.',
                    font,
                    boldFont,
                  ),
                  pw.SizedBox(height: 20),

                  _buildSectionHeader('Học vấn', boldFont),
                  pw.Text(
                    'Cử nhân Kỹ thuật phần mềm - Đại học Bách Khoa (2016-2020)',
                    style: pw.TextStyle(font: font, fontSize: 12),
                  ),
                ],
              ),
            )
          ],
        );
      },
    ),
  );

  return doc.save(); // Trả về Future<Uint8List>
}

// Tiêu đề phần
pw.Widget _buildSectionHeader(String title, pw.Font boldFont) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        title.toUpperCase(),
        style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColors.blueGrey800),
      ),
      pw.Container(height: 2, width: 40, color: PdfColors.blueGrey800),
      pw.SizedBox(height: 10),
    ],
  );
}

// Mục kinh nghiệm làm việc
pw.Widget _buildExperienceItem(
    String company,
    String duration,
    String description,
    pw.Font font,
    pw.Font boldFont,
    ) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(company, style: pw.TextStyle(font: boldFont, fontSize: 12)),
      pw.Text(duration, style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey600)),
      pw.SizedBox(height: 5),
      pw.Text(description, style: pw.TextStyle(font: font, fontSize: 12)),
      pw.SizedBox(height: 10),
    ],
  );
}
