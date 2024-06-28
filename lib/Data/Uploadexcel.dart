import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:attendance/Data/lists_data.dart';

class Excelupload{
  static Future<List<dynamic>> pickExcelFile() async {
    List<dynamic> CurrRolls=[];
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      CurrRolls = processExcelFile(filePath);
    } else {
      // User canceled the picker
    }
    return CurrRolls;
  }
  static List<dynamic> processExcelFile(String filePath) {
    var bytes = File(filePath).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    rollNumber=[];
    for (var table in excel.tables.keys) {
      if (excel.tables[table] != null) {
        var sheet = excel.tables[table]!.rows;

        for (int i = 1; i < sheet.length; i++) {
          // Assuming roll number is in the first column
          var rollNumbers = sheet[i][0]?.value.toString();
          if (rollNumbers != null) {
            rollNumber.add(rollNumbers);
          }
        }
      }
    }
    return rollNumber;
  }
}