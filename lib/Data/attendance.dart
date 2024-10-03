import 'dart:io';
import 'package:attendance/Data/lists_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' as html;

class PdfApi {
  static Future<File?> generatePDF(String deptvalue, String yearvalue, String sectionvalue) async {
    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);
    print(StudentsData);
    String studentID = StudentsData[0][0];
    String yearPrefix = studentID.substring(0, 2);
    int startYear = 2000 + int.parse(yearPrefix); // e.g., 21 -> 2021
    int endYear = startYear + 4; // A 4-year span

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        margin: pw.EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        pageFormat: PdfPageFormat.a3,
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'Sagi Rama Krishnam Raju Engineering College',
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
                font: ttf,
              ),
            ),
          ),
          pw.SizedBox(height: 5.0), // Space between headers
          pw.Center(
            child: pw.Text(
              '$deptvalue,$yearvalue,$sectionvalue Section,$startYear-$endYear',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                font: ttf,
              ),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Header(
            level: 1,
            child: pw.Center(
              child: pw.Text(
                'Students Attendance Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  font: ttf,
                ),
              ),
            ),
          ),
          pw.Table.fromTextArray(
            data: StudentsData,
            headers: PdfHeader,
            columnWidths: {
              0: pw.FixedColumnWidth(70),
            },
            cellStyle: pw.TextStyle(
              fontSize: 9.0,
            ),
            headerStyle: pw.TextStyle(
              fontSize: 8.0,
            ),
          ),
        ],
      ),
    );

    final bytes = await pdf.save();

    if (kIsWeb) {
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'students_attendance_report.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
      return null; // No file object to return for web
    } else {
      final directory = await getExternalStorageDirectory();
      final file = File('${directory?.path}/students_attendance_report.pdf');
      await file.writeAsBytes(bytes);
      return file;
    }
  }

  static Future<void> openFile(File? file) async {
    if (file == null) return;

    if (kIsWeb) {
      // File opening handled in generatePDF for web
    } else {
      final url = file.path;
      await OpenFile.open(url);
    }
  }
}
