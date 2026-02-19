import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/diary_entry.dart';

class PdfService {
  /// Generate PDF from a diary entry
  Future<Uint8List> generateEntryPdf(DiaryEntry entry) async {
    final pdf = pw.Document();

    // Pre-load images to Uint8List
    final List<Uint8List> imageBytesList = [];
    for (final path in entry.images.take(4)) {
      try {
        if (path.startsWith('data:image')) {
          final base64String = path.split(',').last;
          imageBytesList.add(base64Decode(base64String));
        } else if (path.startsWith('http')) {
          final response = await http.get(Uri.parse(path));
          if (response.statusCode == 200) {
            imageBytesList.add(response.bodyBytes);
          }
        } else {
          final file = File(path);
          if (await file.exists()) {
            imageBytesList.add(await file.readAsBytes());
          }
        }
      } catch (e) {
        print('Error loading image for PDF: $e');
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.cyan50,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      entry.title,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.cyan900,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          DateFormat('EEEE, MMMM d, y').format(entry.date),
                          style: const pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey700,
                          ),
                        ),
                        if (entry.mood.isNotEmpty)
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.cyan,
                              borderRadius: pw.BorderRadius.circular(12),
                            ),
                            child: pw.Text(
                              entry.mood,
                              style: const pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Content
              pw.Text(
                entry.content,
                style: const pw.TextStyle(
                  fontSize: 14,
                  lineSpacing: 1.5,
                ),
              ),

              pw.SizedBox(height: 20),

              // Images (if any)
              if (imageBytesList.isNotEmpty) ...[
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Attached Images',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: imageBytesList.map((bytes) {
                    return pw.Container(
                      width: 160,
                      height: 160,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.ClipRRect(
                        horizontalRadius: 8,
                        verticalRadius: 8,
                        child: pw.Image(
                          pw.MemoryImage(bytes),
                          fit: pw.BoxFit.cover,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              pw.Spacer(),

              // Footer
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'Generated by Personal Diary App',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Save PDF to device
  Future<String> savePdfToDevice(Uint8List pdfBytes, String fileName) async {
    if (kIsWeb) {
      // On web, trigger download
      await Printing.sharePdf(bytes: pdfBytes, filename: '$fileName.pdf');
      return 'Downloaded as $fileName.pdf';
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName.pdf');
      await file.writeAsBytes(pdfBytes);
      return file.path;
    }
  }

  /// Share PDF
  Future<void> sharePdf(Uint8List pdfBytes, String fileName) async {
    if (kIsWeb) {
      // On web, use printing package's share
      await Printing.sharePdf(bytes: pdfBytes, filename: '$fileName.pdf');
    } else {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName.pdf');
      await file.writeAsBytes(pdfBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Diary Entry: $fileName',
      );
    }
  }

  /// Print PDF
  Future<void> printPdf(Uint8List pdfBytes) async {
    if (kIsWeb) {
      // On web, open print dialog
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    } else {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    }
  }
}
