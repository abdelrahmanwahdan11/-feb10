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
            child: Text('${tr.t('formulaSupportTip')} | ${tr.t('sortState')}: ${_sortAscending ? tr.t('ascending') : tr.t('descending')}'),
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
