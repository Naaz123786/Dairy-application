import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/diary_entry.dart';
import '../util/json_utils.dart';

class PdfService {
  /// Generate PDF from a diary entry
  Future<Uint8List> generateEntryPdf(DiaryEntry entry) async {
    final pdf = pw.Document();

    // Pre-load images to Uint8List
    final List<Uint8List> imageBytesList = [];
    for (final path in entry.images) {
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
        debugPrint('Error loading image for PDF: $e');
      }
    }

    // Content Rendering (Rich Text to Plain Text fallback)
    String displayContent = entry.content;
    try {
      if (displayContent.trim().startsWith('[') ||
          displayContent.trim().startsWith('{')) {
        final decoded = JsonUtils.safeDecode(displayContent);
        final ops = JsonUtils.getOps(decoded);

        if (ops != null) {
          final StringBuffer buffer = StringBuffer();
          for (final op in ops) {
            if (op is Map && op.containsKey('insert')) {
              final insert = op['insert'];
              if (insert is String) {
                buffer.write(insert);
              }
            }
          }
          displayContent = buffer.toString();
        }
      }
    } catch (e) {
      debugPrint('Error parsing rich text for PDF: $e');
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          final widgets = <pw.Widget>[];

          widgets.add(
            pw.Container(
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                color: PdfColors.cyan50,
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    entry.title,
                    style: pw.TextStyle(
                      fontSize: 22,
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
                          fontSize: 11,
                          color: PdfColors.grey700,
                        ),
                      ),
                      if (entry.mood.isNotEmpty)
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 10,
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
          );

          widgets.add(pw.SizedBox(height: 16));

          widgets.add(
            pw.Text(
              displayContent,
              style: const pw.TextStyle(
                fontSize: 13,
                lineSpacing: 1.5,
              ),
            ),
          );

          if (imageBytesList.isNotEmpty) {
            widgets.add(pw.SizedBox(height: 18));
            widgets.add(pw.Divider());
            widgets.add(pw.SizedBox(height: 10));
            widgets.add(
              pw.Text(
                'Attached Images (${imageBytesList.length})',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
            );
            widgets.add(pw.SizedBox(height: 10));
            widgets.add(
              pw.Wrap(
                spacing: 10,
                runSpacing: 10,
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
            );
          }

          return widgets;
        },
        footer: (context) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 10),
          child: pw.Column(
            children: [
              pw.Divider(),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Generated by My Diary',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Text(
                    'Page ${context.pageNumber} / ${context.pagesCount}',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }
}
