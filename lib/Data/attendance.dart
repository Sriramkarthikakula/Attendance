import 'dart:io';
import 'package:attendance/Data/lists_data.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';



class PdfApi {
  static Future<File> generatePDF() async {
    // Step 1: Load font data
    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    // Step 2: Create PDF document
    final pdf = pw.Document();
    // Create a map for column widths, setting a fixed width for each column
    // final columnWidths = <int, pw.TableColumnWidth>{
    //   0: pw.FixedColumnWidth(50), // First column fixed width
    //   for (int i = 1; i < columnCount; i++) i: pw.FlexColumnWidth(), // Remaining columns flexible
    // };
    // Step 3: Add content to PDF
    pdf.addPage(
      pw.MultiPage(
        margin: pw.EdgeInsets.symmetric(horizontal: 10.0,vertical:10.0),
          pageFormat: PdfPageFormat.a3,
        build: (context) => [
          pw.Header(
            level: 1,
            child: pw.Center(
              child:pw.Text(
              'Students Attendance Report',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                font: ttf,
              ),
            ),),
          ),
          pw.TableHelper.fromTextArray(
          data:StudentsData,
          headers: PdfHeader,
          // tableWidth: pw.TableWidth.max,
          columnWidths:{
            0:pw.FixedColumnWidth(70),
          },
          // cellPadding: pw.EdgeInsets.all(1.5),
          cellStyle: pw.TextStyle(
            fontSize: 9.0,
          ),
          // headerPadding: pw.EdgeInsets.symmetric(horizontal: 3.0),
          headerStyle: pw.TextStyle(
            fontSize: 8.0,
          ),
        ),]
        )
      );

    // Step 4: Save PDF to file
    final bytes = await pdf.save();
    final directory = await getExternalStorageDirectory(); // Changed to external storage directory for better accessibility
    final file = File('${directory?.path}/karthik.pdf');

    // Step 5: Write PDF bytes to file
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<void> openFile(File file) async {
    final url = file.path;
    await OpenFile.open(url);
  }
}
