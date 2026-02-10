import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class ExcelService {
  Future<String> createDemoReport() async {
    final workbook = Workbook();
    final sheet = workbook.worksheets[0];

    sheet.getRangeByName('A1').setText('Month');
    sheet.getRangeByName('B1').setText('Sales');
    sheet.getRangeByName('A2').setText('Jan');
    sheet.getRangeByName('B2').setNumber(1200);
    sheet.getRangeByName('A3').setText('Feb');
    sheet.getRangeByName('B3').setNumber(1500);
    sheet.getRangeByName('A4').setText('Mar');
    sheet.getRangeByName('B4').setNumber(1700);

    final style = workbook.styles.add('headerStyle');
    style.bold = true;
    style.backColor = '#DDE7FF';
    sheet.getRangeByName('A1:B1').cellStyle = style;

    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/excel_ai_demo_report.xlsx');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<String> previewFile(PlatformFile file) async {
    final ext = file.extension?.toLowerCase();
    final path = file.path;

    if (path == null) return 'File path not available.';

    if (ext == 'csv') {
      final lines = await File(path).readAsLines();
      if (lines.isEmpty) return 'CSV file is empty.';
      return lines.take(6).join('\n');
    }

    if (ext == 'xlsx' || ext == 'xls' || ext == 'xlsm') {
      return 'Spreadsheet selected successfully. Detailed preview can be added in next phase.';
    }

    return 'Unsupported file format.';
  }
}
