import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_localizations.dart';
import 'excel_service.dart';
import 'spreadsheet_document.dart';

class SpreadsheetEditorScreen extends StatefulWidget {
  const SpreadsheetEditorScreen({super.key});

  @override
  State<SpreadsheetEditorScreen> createState() => _SpreadsheetEditorScreenState();
}

class _SpreadsheetEditorScreenState extends State<SpreadsheetEditorScreen> {
  final _doc = SpreadsheetDocument();
  final _service = ExcelService();
  int _selectedRow = 0;
  int _selectedCol = 0;
  bool _sortAscending = true;

  String _colName(int index) {
    var n = index + 1;
    var name = '';
    while (n > 0) {
      final rem = (n - 1) % 26;
      name = String.fromCharCode(65 + rem) + name;
      n = (n - 1) ~/ 26;
    }
    return name;
  }

  Future<void> _editCell(int row, int col) async {
    final tr = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: _doc.valueAt(row, col));
    final val = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${tr.t('editCell')} ${_colName(col)}${row + 1}'),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(hintText: tr.t('cellHint')),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(tr.t('cancel'))),
          FilledButton(onPressed: () => Navigator.pop(context, ctrl.text), child: Text(tr.t('save'))),
        ],
      ),
    );

    if (val != null) {
      setState(() {
        _doc.snapshot();
        _selectedRow = row;
        _selectedCol = col;
        _doc.setValue(row, col, val.trim());
      });
    }
  }

  Future<void> _pasteTable() async {
    final tr = AppLocalizations.of(context);
    final data = await Clipboard.getData('text/plain');
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) return;

    final rows = text.split('\n').map((e) => e.split('\t')).toList();
    setState(() {
      _doc.snapshot();
      while (_doc.rows < _selectedRow + rows.length) {
        _doc.addRow();
      }
      var maxColsNeeded = _selectedCol;
      for (final row in rows) {
        final needed = _selectedCol + row.length;
        if (needed > maxColsNeeded) maxColsNeeded = needed;
      }
      while (_doc.columns < maxColsNeeded) {
        _doc.addColumn();
      }

      for (var r = 0; r < rows.length; r++) {
        for (var c = 0; c < rows[r].length; c++) {
          _doc.setValue(_selectedRow + r, _selectedCol + c, rows[r][c]);
        }
      }
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr.t('pastedRange'))));
  }

  Future<void> _clearSheet() async {
    final tr = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr.t('clearSheet')),
        content: Text(tr.t('confirmClearSheet')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(tr.t('cancel'))),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(tr.t('yes'))),
        ],
      ),
    );

    if (ok != true) return;
    setState(() {
      _doc.snapshot();
      for (var r = 0; r < _doc.rows; r++) {
        for (var c = 0; c < _doc.columns; c++) {
          _doc.setValue(r, c, '');
        }
      }
    });
  }


  Future<void> _fillDownFromSelection() async {
    final tr = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: '${_selectedRow + 1}');
    final toRow = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr.t('fillDown')),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: tr.t('endRowHint')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(tr.t('cancel'))),
          FilledButton(
            onPressed: () => Navigator.pop(context, int.tryParse(ctrl.text)),
            child: Text(tr.t('apply')),
          ),
        ],
      ),
    );

    if (toRow == null) return;
    final target = toRow - 1;
    if (target <= _selectedRow) return;

    setState(() {
      _doc.snapshot();
      _doc.fillDown(fromRow: _selectedRow, toRow: target, col: _selectedCol);
    });
  }

  void _sortBySelectedColumn() {
    setState(() {
      _doc.snapshot();
      _doc.sortByColumn(col: _selectedCol, ascending: _sortAscending, hasHeader: true);
      _sortAscending = !_sortAscending;
    });
  }

  Future<void> _showColumnStats() async {
    final tr = AppLocalizations.of(context);
    final stats = _doc.columnStats(_selectedCol, skipHeader: true);
    String fmt(double? v) => v == null ? '-' : v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${tr.t('columnStats')} ${_colName(_selectedCol)}'),
        content: Text(
          '${tr.t('count')}: ${stats.count}\n${tr.t('minValue')}: ${fmt(stats.min)}\n${tr.t('maxValue')}: ${fmt(stats.max)}\n${tr.t('avgValue')}: ${fmt(stats.avg)}',
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(context), child: Text(tr.t('ok'))),
        ],
      ),
    );
  }


  Future<void> _showColumnDeepStats() async {
    final tr = AppLocalizations.of(context);
    final stats = _doc.columnAdvancedStats(_selectedCol, skipHeader: true);
    String fmt(double? v) => v == null ? '-' : v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${tr.t('columnDeepStats')} ${_colName(_selectedCol)}'),
        content: Text(
          '${tr.t('count')}: ${stats.count}\n${tr.t('sumValue')}: ${fmt(stats.sum)}\n${tr.t('medianValue')}: ${fmt(stats.median)}\n${tr.t('varianceValue')}: ${fmt(stats.variance)}\n${tr.t('stdevValue')}: ${fmt(stats.stdev)}',
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(context), child: Text(tr.t('ok'))),
        ],
      ),
    );
  }

  void _duplicateSelectedRow() {
    if (_selectedRow < 0 || _selectedRow >= _doc.rows) return;
    setState(() {
      _doc.snapshot();
      _doc.addRow();
      for (var r = _doc.rows - 1; r > _selectedRow + 1; r--) {
        for (var c = 0; c < _doc.columns; c++) {
          _doc.setValue(r, c, _doc.valueAt(r - 1, c));
        }
      }
      for (var c = 0; c < _doc.columns; c++) {
        _doc.setValue(_selectedRow + 1, c, _doc.valueAt(_selectedRow, c));
      }
      _selectedRow += 1;
    });
  }

  Future<void> _findInSheet() async {
    final tr = AppLocalizations.of(context);
    final ctrl = TextEditingController();
    final query = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr.t('findInSheet')),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(hintText: tr.t('findHint')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(tr.t('cancel'))),
          FilledButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: Text(tr.t('find'))),
        ],
      ),
    );

    if (query == null || query.isEmpty) return;
    final matches = _doc.findMatches(query);
    if (matches.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr.t('noMatches'))));
      return;
    }

    setState(() {
      _selectedRow = matches.first.$1;
      _selectedCol = matches.first.$2;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${tr.t('matchesFound')}: ${matches.length}')),
    );
  }

  Future<void> _replaceInSheet() async {
    final tr = AppLocalizations.of(context);
    final findCtrl = TextEditingController();
    final replaceCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr.t('replaceInSheet')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: findCtrl, decoration: InputDecoration(labelText: tr.t('find'))),
            const SizedBox(height: 8),
            TextField(controller: replaceCtrl, decoration: InputDecoration(labelText: tr.t('replaceWith'))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(tr.t('cancel'))),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(tr.t('apply'))),
        ],
      ),
    );

    if (ok != true) return;
    final findText = findCtrl.text.trim();
    if (findText.isEmpty) return;

    int count = 0;
    setState(() {
      _doc.snapshot();
      count = _doc.replaceAll(findText, replaceCtrl.text);
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${tr.t('replacedCount')}: $count')),
    );
  }

  Future<void> _deleteSelectedRow() async {
    final tr = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr.t('deleteRow')),
        content: Text(tr.t('confirmDeleteRow')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(tr.t('cancel'))),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(tr.t('yes'))),
        ],
      ),
    );
    if (ok != true) return;

    setState(() {
      _doc.snapshot();
      final deleted = _doc.deleteRow(_selectedRow);
      if (deleted && _selectedRow >= _doc.rows) _selectedRow = _doc.rows - 1;
    });
  }

  Future<void> _deleteSelectedColumn() async {
    final tr = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr.t('deleteColumn')),
        content: Text(tr.t('confirmDeleteColumn')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(tr.t('cancel'))),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(tr.t('yes'))),
        ],
      ),
    );
    if (ok != true) return;

    setState(() {
      _doc.snapshot();
      final deleted = _doc.deleteColumn(_selectedCol);
      if (deleted && _selectedCol >= _doc.columns) _selectedCol = _doc.columns - 1;
    });
  }



  Future<void> _insertRowBelow() async {
    setState(() {
      _doc.snapshot();
      _doc.insertRow(_selectedRow + 1);
      _selectedRow += 1;
    });
  }

  Future<void> _insertColumnRight() async {
    setState(() {
      _doc.snapshot();
      _doc.insertColumn(_selectedCol + 1);
      _selectedCol += 1;
    });
  }

  Future<void> _goToCell() async {
    final tr = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: '${_colName(_selectedCol)}${_selectedRow + 1}');
    final target = await showDialog<(int, int)>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr.t('goToCell')),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'A1'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(tr.t('cancel'))),
          FilledButton(
            onPressed: () {
              final match = RegExp(r'^([A-Za-z]+)(\d+)$').firstMatch(ctrl.text.trim());
              if (match == null) {
                Navigator.pop(context);
                return;
              }
              final letters = match.group(1)!.toUpperCase();
              final row = int.tryParse(match.group(2)!);
              if (row == null) {
                Navigator.pop(context);
                return;
              }
              var col = 0;
              for (final code in letters.codeUnits) {
                col = col * 26 + (code - 64);
              }
              Navigator.pop(context, (row - 1, col - 1));
            },
            child: Text(tr.t('go')),
          ),
        ],
      ),
    );

    if (target == null) return;
    final r = target.$1;
    final c = target.$2;
    if (r < 0 || c < 0) return;

    if (r >= _doc.rows || c >= _doc.columns) {
      final expand = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(tr.t('goToCell')),
          content: Text(tr.t('autoExpandPrompt')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(tr.t('cancel'))),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(tr.t('yes'))),
          ],
        ),
      );
      if (expand != true) return;

      setState(() {
        _doc.snapshot();
        _doc.ensureSize(minRows: r + 1, minColumns: c + 1);
      });
    }

    setState(() {
      _selectedRow = r;
      _selectedCol = c;
    });
  }

  Future<void> _trimTrailingEmpty() async {
    final tr = AppLocalizations.of(context);
    var removed = 0;
    setState(() {
      _doc.snapshot();
      removed = _doc.trimTrailingEmpty();
      if (_selectedRow >= _doc.rows) _selectedRow = _doc.rows - 1;
      if (_selectedCol >= _doc.columns) _selectedCol = _doc.columns - 1;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${tr.t('sheetTrimmed')}: $removed')),
    );
  }

  Future<void> _runFormulaAudit() async {
    final tr = AppLocalizations.of(context);
    final issues = _doc.formulaDiagnostics();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr.t('formulaAudit')),
        content: SizedBox(
          width: 420,
          child: issues.isEmpty
              ? Text(tr.t('formulaAuditClean'))
              : SingleChildScrollView(child: Text(issues.join('\n'))),
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(context), child: Text(tr.t('ok'))),
        ],
      ),
    );
  }



  Future<void> _optimizeSheet() async {
    final tr = AppLocalizations.of(context);
    var removedRows = 0;
    var removedCols = 0;
    setState(() {
      _doc.snapshot();
      removedRows = _doc.removeFullyEmptyRows(keepHeader: true);
      removedCols = _doc.removeFullyEmptyColumns(keepFirstColumn: false);
      if (_selectedRow >= _doc.rows) _selectedRow = _doc.rows - 1;
      if (_selectedCol >= _doc.columns) _selectedCol = _doc.columns - 1;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${tr.t('sheetOptimized')}: R-$removedRows / C-$removedCols')),
    );
  }




  Future<void> _normalizeSelectedColumn() async {
    final tr = AppLocalizations.of(context);
    var updated = 0;
    setState(() {
      _doc.snapshot();
      updated = _doc.normalizeColumnZScore(_selectedCol, skipHeader: true);
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${tr.t('normalizedCells')}: $updated')),
    );
  }

  Future<void> _detectOutliers() async {
    final tr = AppLocalizations.of(context);
    final rows = _doc.detectOutlierRowsIqr(_selectedCol, skipHeader: true);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${tr.t('outlierDetection')} ${_colName(_selectedCol)}'),
        content: Text(
          rows.isEmpty ? tr.t('noOutliers') : '${tr.t('outlierRows')}: ${rows.map((e) => e + 1).join(', ')}',
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(context), child: Text(tr.t('ok'))),
        ],
      ),
    );
  }


  Future<void> _showTrendInsights() async {
    final tr = AppLocalizations.of(context);
    final line = _doc.trendLine(0, _selectedCol, skipHeader: true);
    final forecasts = _doc.forecastNextRows(xCol: 0, yCol: _selectedCol, predictCount: 3, skipHeader: true);

    String fmt(double v) => v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 3);
    final forecastText = forecasts.isEmpty
        ? '-'
        : forecasts.map((f) => '+${f.$1}: ${fmt(f.$2)}').join('\n');

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${tr.t('trendInsights')} ${_colName(_selectedCol)}'),
        content: Text(
          '${tr.t('trendSlope')}: ${fmt(line.slope)}\n${tr.t('trendIntercept')}: ${fmt(line.intercept)}\n${tr.t('samplesUsed')}: ${line.samples}\n\n${tr.t('nextForecasts')}:\n$forecastText',
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(context), child: Text(tr.t('ok'))),
        ],
      ),
    );
  }

  Future<void> _applyMovingAverageToSelected() async {
    final tr = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: '3');
    final window = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr.t('movingAverage')),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: tr.t('windowSizeHint')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(tr.t('cancel'))),
          FilledButton(onPressed: () => Navigator.pop(context, int.tryParse(ctrl.text)), child: Text(tr.t('apply'))),
        ],
      ),
    );

    if (window == null || window < 2) return;
    setState(() {
      _doc.snapshot();
      if (_selectedCol == _doc.columns - 1) {
        _doc.addColumn();
      }
      _doc.applyMovingAverage(sourceCol: _selectedCol, targetCol: _selectedCol + 1, window: window, skipHeader: true);
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${tr.t('movingAverageApplied')}: ${_colName(_selectedCol + 1)}')),
    );
  }

  Future<void> _openFormulaAssistant() async {
    final tr = AppLocalizations.of(context);
    final templates = <String>[
      '=SUM(A2:A20)',
      '=AVG(B2:B20)',
      '=MEDIAN(C2:C20)',
      '=STDEV(D2:D20)',
      '=PCTL(E2:E20,0.9)',
      '=RANK(E2,E2:E20)',
      '=IF(A2>100,"High","Low")',
    ];

    final formula = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr.t('formulaAssistant')),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: templates
                  .map(
                    (item) => ActionChip(
                      label: Text(item),
                      onPressed: () => Navigator.pop(context, item),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(tr.t('cancel'))),
        ],
      ),
    );

    if (formula == null || formula.isEmpty) return;
    setState(() {
      _doc.snapshot();
      _doc.setValue(_selectedRow, _selectedCol, formula);
    });
  }

  Future<void> _saveCsv() async {
    final tr = AppLocalizations.of(context);
    final path = await _service.saveDocumentAsCsv(_doc.rawCells, 'sheet_editor_export');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${tr.t('savedTo')}: $path')));
  }

  Future<void> _saveXlsx() async {
    final tr = AppLocalizations.of(context);
    final path = await _service.saveDocumentAsXlsx(_doc.rawCells, 'sheet_editor_export');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${tr.t('savedTo')}: $path')));
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.t('sheetEditor')),
        actions: [
          IconButton(onPressed: _saveCsv, icon: const Icon(Icons.description_outlined), tooltip: tr.t('saveCsv')),
          IconButton(onPressed: _saveXlsx, icon: const Icon(Icons.grid_on_rounded), tooltip: tr.t('saveXlsx')),
          IconButton(onPressed: _pasteTable, icon: const Icon(Icons.content_paste_rounded), tooltip: tr.t('pasteTable')),
          IconButton(onPressed: _fillDownFromSelection, icon: const Icon(Icons.vertical_align_bottom_rounded), tooltip: tr.t('fillDown')),
          IconButton(onPressed: _sortBySelectedColumn, icon: const Icon(Icons.sort_rounded), tooltip: tr.t('sortByColumn')),
          IconButton(onPressed: _showColumnStats, icon: const Icon(Icons.query_stats_rounded), tooltip: tr.t('columnStats')),
          IconButton(onPressed: _showColumnDeepStats, icon: const Icon(Icons.insights_rounded), tooltip: tr.t('columnDeepStats')),
          IconButton(onPressed: _showTrendInsights, icon: const Icon(Icons.show_chart_rounded), tooltip: tr.t('trendInsights')),
          IconButton(onPressed: _applyMovingAverageToSelected, icon: const Icon(Icons.multiline_chart_rounded), tooltip: tr.t('movingAverage')),
          IconButton(onPressed: _normalizeSelectedColumn, icon: const Icon(Icons.auto_graph_rounded), tooltip: tr.t('normalizeColumn')),
          IconButton(onPressed: _detectOutliers, icon: const Icon(Icons.warning_amber_rounded), tooltip: tr.t('outlierDetection')),
          IconButton(onPressed: _openFormulaAssistant, icon: const Icon(Icons.functions_rounded), tooltip: tr.t('formulaAssistant')),
          IconButton(onPressed: _duplicateSelectedRow, icon: const Icon(Icons.copy_all_rounded), tooltip: tr.t('duplicateRow')),
          IconButton(onPressed: _insertRowBelow, icon: const Icon(Icons.playlist_add_rounded), tooltip: tr.t('insertRowBelow')),
          IconButton(onPressed: _insertColumnRight, icon: const Icon(Icons.add_box_outlined), tooltip: tr.t('insertColumnRight')),
          IconButton(onPressed: _goToCell, icon: const Icon(Icons.my_location_rounded), tooltip: tr.t('goToCell')),
          IconButton(onPressed: _trimTrailingEmpty, icon: const Icon(Icons.cleaning_services_outlined), tooltip: tr.t('trimSheet')),
          IconButton(onPressed: _optimizeSheet, icon: const Icon(Icons.auto_fix_high_outlined), tooltip: tr.t('optimizeSheet')),
          IconButton(onPressed: _runFormulaAudit, icon: const Icon(Icons.rule_folder_outlined), tooltip: tr.t('formulaAudit')),
          IconButton(onPressed: _deleteSelectedRow, icon: const Icon(Icons.remove_circle_outline_rounded), tooltip: tr.t('deleteRow')),
          IconButton(onPressed: _deleteSelectedColumn, icon: const Icon(Icons.view_column_outlined), tooltip: tr.t('deleteColumn')),
          IconButton(onPressed: _findInSheet, icon: const Icon(Icons.search_rounded), tooltip: tr.t('findInSheet')),
          IconButton(onPressed: _replaceInSheet, icon: const Icon(Icons.find_replace_rounded), tooltip: tr.t('replaceInSheet')),
          IconButton(onPressed: _clearSheet, icon: const Icon(Icons.delete_sweep_rounded), tooltip: tr.t('clearSheet')),
          IconButton(
            onPressed: _doc.canUndo ? () => setState(() => _doc.undo()) : null,
            icon: const Icon(Icons.undo_rounded),
            tooltip: tr.t('undo'),
          ),
          IconButton(
            onPressed: _doc.canRedo ? () => setState(() => _doc.redo()) : null,
            icon: const Icon(Icons.redo_rounded),
            tooltip: tr.t('redo'),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            onPressed: () => setState(() {
              _doc.snapshot();
              _doc.addColumn();
            }),
            heroTag: 'add_col',
            child: const Icon(Icons.view_column),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.small(
            onPressed: () => setState(() {
              _doc.snapshot();
              _doc.addRow();
            }),
            heroTag: 'add_row',
            child: const Icon(Icons.view_agenda),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.primaryContainer,
            padding: const EdgeInsets.all(12),
            child: Text(
              '${tr.t('selectedCell')}: ${_colName(_selectedCol)}${_selectedRow + 1} | ${tr.t('value')}: ${_doc.valueAt(_selectedRow, _selectedCol)} | ${tr.t('resolved')}: ${_doc.resolvedValue(_selectedRow, _selectedCol)}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text('${tr.t('formulaSupportTip')} | ${tr.t('arithmeticFormulasTip')} | ${tr.t('advancedFormulaTip')} | ${tr.t('conditionalFormulaTip')} | ${tr.t('dispersionFormulaTip')} | ${tr.t('rankingFormulaTip')} | ${tr.t('outlierTip')} | ${tr.t('trendTip')} | ${tr.t('sortState')}: ${_sortAscending ? tr.t('ascending') : tr.t('descending')}'),
          ),
          Expanded(
            child: Scrollbar(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: [
                      const DataColumn(label: Text('#')),
                      ...List.generate(_doc.columns, (c) => DataColumn(label: Text(_colName(c)))),
                    ],
                    rows: List.generate(
                      _doc.rows,
                      (r) => DataRow(
                        cells: [
                          DataCell(Text('${r + 1}')),
                          ...List.generate(
                            _doc.columns,
                            (c) {
                              final raw = _doc.valueAt(r, c);
                              final resolved = _doc.resolvedValue(r, c);
                              final display = raw.startsWith('=') ? '$raw → $resolved' : raw;
                              return DataCell(
                                ConstrainedBox(
                                  constraints: const BoxConstraints(minWidth: 110, maxWidth: 180),
                                  child: Text(display, overflow: TextOverflow.ellipsis),
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedRow = r;
                                    _selectedCol = c;
                                  });
                                  _editCell(r, c);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
