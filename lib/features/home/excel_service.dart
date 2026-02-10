import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

enum PreviewStatus {
  pathMissing,
  csvEmpty,
  spreadsheetSelected,
  unsupported,
  previewData,
}

class FilePreviewResult {
  const FilePreviewResult({required this.status, required this.content});

  final PreviewStatus status;
  final String content;
}

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

  Future<FilePreviewResult> previewFile(PlatformFile file) async {
    final ext = file.extension?.toLowerCase();
    final path = file.path;

    if (path == null) {
      return const FilePreviewResult(status: PreviewStatus.pathMissing, content: '');
    }

    if (ext == 'csv') {
      final lines = await File(path).readAsLines();
      if (lines.isEmpty) {
        return const FilePreviewResult(status: PreviewStatus.csvEmpty, content: '');
      }
      return FilePreviewResult(status: PreviewStatus.previewData, content: lines.take(6).join('\n'));
    }

    if (ext == 'xlsx' || ext == 'xls' || ext == 'xlsm') {
      return const FilePreviewResult(status: PreviewStatus.spreadsheetSelected, content: '');
    }

    return const FilePreviewResult(status: PreviewStatus.unsupported, content: '');
  }

  Future<String> saveDocumentAsCsv(List<List<String>> cells, String baseName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$baseName.csv');
    final lines = cells.map((row) => row.map(_escapeCsv).join(',')).join('\n');
    await file.writeAsString(lines, flush: true);
    return file.path;
  }

  Future<String> saveDocumentAsXlsx(List<List<String>> cells, String baseName) async {
    final workbook = Workbook();
    final sheet = workbook.worksheets[0];
    for (var r = 0; r < cells.length; r++) {
      final row = cells[r];
      for (var c = 0; c < row.length; c++) {
        sheet.getRangeByIndex(r + 1, c + 1).setText(row[c]);
      }
    }
    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$baseName.xlsx');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  String _escapeCsv(String cell) {
    final hasSpecial = cell.contains(',') || cell.contains('"') || cell.contains('\n');
    if (!hasSpecial) return cell;
    return '"${cell.replaceAll('"', '""')}"';
  }

  Future<String> createBudgetTemplate() async {
    final workbook = Workbook();
    final sheet = workbook.worksheets[0];

    sheet.getRangeByName('A1').setText('Category');
    sheet.getRangeByName('B1').setText('Planned');
    sheet.getRangeByName('C1').setText('Actual');
    sheet.getRangeByName('D1').setText('Variance');

    final rows = ['Rent', 'Utilities', 'Food', 'Transport'];
    for (var i = 0; i < rows.length; i++) {
      final r = i + 2;
      sheet.getRangeByName('A$r').setText(rows[i]);
      sheet.getRangeByName('B$r').setNumber(1000 + i * 100);
      sheet.getRangeByName('C$r').setNumber(950 + i * 120);
      sheet.getRangeByName('D$r').setFormula('=C$r-B$r');
    }

    return _saveWorkbook(workbook, 'budget_template.xlsx');
  }

  Future<String> createInvoiceTemplate() async {
    final workbook = Workbook();
    final sheet = workbook.worksheets[0];

    sheet.getRangeByName('A1').setText('Item');
    sheet.getRangeByName('B1').setText('Qty');
    sheet.getRangeByName('C1').setText('Price');
    sheet.getRangeByName('D1').setText('Total');

    for (var r = 2; r <= 6; r++) {
      sheet.getRangeByName('A$r').setText('Item $r');
      sheet.getRangeByName('B$r').setNumber(1);
      sheet.getRangeByName('C$r').setNumber(100);
      sheet.getRangeByName('D$r').setFormula('=B$r*C$r');
    }
    sheet.getRangeByName('C8').setText('Grand Total');
    sheet.getRangeByName('D8').setFormula('=SUM(D2:D6)');

    return _saveWorkbook(workbook, 'invoice_template.xlsx');
  }

  Future<String> _saveWorkbook(Workbook workbook, String fileName) async {
    final bytes = workbook.saveAsStream();
    workbook.dispose();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

}
