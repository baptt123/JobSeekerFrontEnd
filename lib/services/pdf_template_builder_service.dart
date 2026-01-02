import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../dto/create_cv_dto.dart';

class PdfTemplateBuilderService{

  Future<Uint8List> buildPdf(CreateCvDto data, {String templateId = 'modern'}) async {
    final pdf = pw.Document();

    // 1. Tải Font chữ & Font Icon (Quan trọng để không bị lỗi ô vuông)
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontItalic = await PdfGoogleFonts.robotoItalic();
    final fontIcons = await PdfGoogleFonts.materialIcons(); // Tải font icon

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        // 2. Cấu hình Theme: Thêm fontIcons vào đây
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
          italic: fontItalic,
          icons: fontIcons, // Đăng ký font icon
        ),
        build: (pw.Context context) {
          switch (templateId) {
            case 'classic':
              return _buildClassicTemplate(data);
            case 'professional':
              return _buildProfessionalTemplate(data);
            case 'creative':
              return _buildCreativeTemplate(data);
            case 'modern':
            default:
              return _buildModernTemplate(data);
          }
        },
      ),
    );

    return pdf.save();
  }

  // ==========================================
  // 1. MODERN TEMPLATE
  // ==========================================
  pw.Widget _buildModernTemplate(CreateCvDto data) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Container(
            color: PdfColors.blueGrey50,
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildAvatarPlaceholder(),
                pw.SizedBox(height: 20),
                _buildSectionTitle("LIÊN HỆ", color: PdfColors.blue800),
                // XÓA const ở đây để tránh lỗi
                _buildInfoRow(data.email, icon: const pw.IconData(0xe158)), // email
                _buildInfoRow(data.phone, icon: const pw.IconData(0xe0b0)), // phone
                _buildInfoRow(data.address, icon: const pw.IconData(0xe0c8)), // location
                pw.SizedBox(height: 20),
                _buildSectionTitle("KỸ NĂNG", color: PdfColors.blue800),
                ...data.skills.map((s) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Bullet(text: s.name, style: const pw.TextStyle(fontSize: 11)),
                )),
              ],
            ),
          ),
        ),
        pw.Expanded(
          flex: 4,
          child: pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(data.fullName.toUpperCase(), style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                pw.Text(data.jobTitle, style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text(data.summary, style: const pw.TextStyle(fontSize: 11)),
                pw.Divider(),
                pw.SizedBox(height: 10),
                _buildSectionTitle("KINH NGHIỆM LÀM VIỆC"),
                ...data.experiences.map((e) => _buildExperienceItem(e)),
                pw.SizedBox(height: 20),
                _buildSectionTitle("HỌC VẤN"),
                ...data.educations.map((e) => _buildEducationItem(e)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 2. CLASSIC TEMPLATE
  // ==========================================
  pw.Widget _buildClassicTemplate(CreateCvDto data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Center(child: pw.Text(data.fullName.toUpperCase(), style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold))),
        pw.SizedBox(height: 5),
        pw.Center(child: pw.Text(data.jobTitle, style: pw.TextStyle(fontSize: 16, fontStyle: pw.FontStyle.italic))),
        pw.SizedBox(height: 5),
        pw.Center(child: pw.Text("${data.email} | ${data.phone} | ${data.address}", style: const pw.TextStyle(fontSize: 10))),
        pw.Divider(thickness: 1),

        pw.SizedBox(height: 10),
        _buildSectionTitle("TÓM TẮT", color: PdfColors.black),
        pw.Text(data.summary, style: const pw.TextStyle(fontSize: 11)),
        pw.SizedBox(height: 15),

        _buildSectionTitle("KINH NGHIỆM", color: PdfColors.black),
        pw.Divider(thickness: 0.5),
        ...data.experiences.map((e) => pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 5),
            child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(width: 80, child: pw.Text(e.duration, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                  pw.Expanded(child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(e.company, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                        pw.Text(e.jobTitle, style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 11)),
                        pw.Text(e.description, style: const pw.TextStyle(fontSize: 10)),
                      ]
                  ))
                ]
            )
        )),

        pw.SizedBox(height: 15),
        _buildSectionTitle("KỸ NĂNG", color: PdfColors.black),
        pw.Divider(thickness: 0.5),
        pw.Wrap(
            spacing: 10,
            children: data.skills.map((s) => pw.Text("• ${s.name}")).toList()
        ),
      ],
    );
  }

  // ==========================================
  // 3. PROFESSIONAL TEMPLATE
  // ==========================================
  pw.Widget _buildProfessionalTemplate(CreateCvDto data) {
    return pw.Column(
        children: [
          pw.Container(
              color: PdfColors.indigo900,
              padding: const pw.EdgeInsets.all(20),
              width: double.infinity,
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(data.fullName, style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    pw.Text(data.jobTitle.toUpperCase(), style: pw.TextStyle(fontSize: 14, color: PdfColors.indigo100, letterSpacing: 2)),
                    pw.SizedBox(height: 10),
                    pw.Row(
                        children: [
                          pw.Text(data.email, style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                          pw.SizedBox(width: 20),
                          pw.Text(data.phone, style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                        ]
                    )
                  ]
              )
          ),
          pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("HỒ SƠ", color: PdfColors.indigo900),
                    pw.Text(data.summary),
                    pw.SizedBox(height: 20),

                    pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                              flex: 3,
                              child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle("KINH NGHIỆM", color: PdfColors.indigo900),
                                    ...data.experiences.map((e) => pw.Container(
                                        margin: const pw.EdgeInsets.only(bottom: 10),
                                        child: pw.Column(
                                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                                            children: [
                                              pw.Text(e.jobTitle, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
                                              pw.Text("${e.company} | ${e.duration}", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                                              pw.Text(e.description, style: const pw.TextStyle(fontSize: 10)),
                                            ]
                                        )
                                    ))
                                  ]
                              )
                          ),
                          pw.SizedBox(width: 20),
                          pw.Expanded(
                              flex: 1,
                              child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle("KỸ NĂNG", color: PdfColors.indigo900),
                                    ...data.skills.map((s) => pw.Container(
                                        margin: const pw.EdgeInsets.only(bottom: 5),
                                        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: const pw.BoxDecoration(color: PdfColors.indigo50),
                                        child: pw.Text(s.name, style: const pw.TextStyle(fontSize: 10))
                                    ))
                                  ]
                              )
                          )
                        ]
                    )
                  ]
              )
          )
        ]
    );
  }

  // ==========================================
  // 4. CREATIVE TEMPLATE
  // ==========================================
  pw.Widget _buildCreativeTemplate(CreateCvDto data) {
    return pw.Row(
        children: [
          pw.Expanded(
              flex: 3,
              child: pw.Padding(
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(data.fullName, style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                        pw.Text(data.jobTitle, style: pw.TextStyle(fontSize: 16, color: PdfColors.teal)),
                        pw.SizedBox(height: 20),
                        pw.Text(data.summary),
                        pw.SizedBox(height: 20),
                        _buildSectionTitle("KINH NGHIỆM", color: PdfColors.teal900),
                        ...data.experiences.map((e) => pw.Container(
                            margin: const pw.EdgeInsets.only(bottom: 15),
                            // XÓA const ở đây
                            decoration: pw.BoxDecoration(
                                border: pw.Border(left: pw.BorderSide(color: PdfColors.teal, width: 2))
                            ),
                            padding: const pw.EdgeInsets.only(left: 10),
                            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                              pw.Text(e.jobTitle, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              pw.Text(e.company, style: const pw.TextStyle(fontSize: 11)),
                              pw.Text(e.description, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                            ])
                        ))
                      ]
                  )
              )
          ),
          pw.Expanded(
              flex: 1,
              child: pw.Container(
                  color: PdfColors.teal50,
                  padding: const pw.EdgeInsets.all(15),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("LIÊN HỆ", color: PdfColors.teal900),
                        pw.Text(data.email, style: const pw.TextStyle(fontSize: 10)),
                        pw.Text(data.phone, style: const pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 30),
                        _buildSectionTitle("HỌC VẤN", color: PdfColors.teal900),
                        ...data.educations.map((e) => pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 10),
                            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children:[
                              pw.Text(e.school, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                              pw.Text(e.degree, style: const pw.TextStyle(fontSize: 10)),
                            ])
                        )),
                        pw.SizedBox(height: 30),
                        _buildSectionTitle("SKILLS", color: PdfColors.teal900),
                        ...data.skills.map((s) => pw.Text(s.name, style:  pw.TextStyle(fontWeight: pw.FontWeight.bold)))
                      ]
                  )
              )
          )
        ]
    );
  }

  // --- Helper Widgets Chung ---

  pw.Widget _buildSectionTitle(String title, {PdfColor color = PdfColors.black}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(title.toUpperCase(), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: color)),
    );
  }

  // ĐÃ SỬA: Hiển thị Icon nếu có
  pw.Widget _buildInfoRow(String text, {pw.IconData? icon}) {
    return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 5),
        child: pw.Row(
            children: [
              if (icon != null)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(right: 6),
                  child: pw.Icon(icon, size: 10, color: PdfColors.blueGrey700),
                ),
              pw.Expanded(child: pw.Text(text, style: const pw.TextStyle(fontSize: 10))),
            ]
        )
    );
  }

  pw.Widget _buildExperienceItem(dynamic e) {
    return pw.Container(margin: const pw.EdgeInsets.only(bottom: 12), child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text(e.jobTitle, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
        pw.Text(e.duration, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
      ]),
      pw.Text(e.company, style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 11)),
      pw.Text(e.description, style: const pw.TextStyle(fontSize: 10)),
    ]));
  }

  pw.Widget _buildEducationItem(dynamic e) {
    return pw.Container(margin: const pw.EdgeInsets.only(bottom: 8), child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text(e.school, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
        pw.Text(e.duration, style: const pw.TextStyle(fontSize: 10)),
      ]),
      pw.Text(e.degree, style: const pw.TextStyle(fontSize: 11)),
    ]));
  }

  pw.Widget _buildAvatarPlaceholder() {
    return pw.Container(width: 60, height: 60, decoration: const pw.BoxDecoration(color: PdfColors.grey300, shape: pw.BoxShape.circle), child: pw.Center(child: pw.Text("IMG")));
  }
}