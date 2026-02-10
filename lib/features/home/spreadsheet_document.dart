class SpreadsheetDocument {
  SpreadsheetDocument({this.rows = 20, this.columns = 10})
      : _cells = List.generate(rows, (_) => List.generate(columns, (_) => ''));

  int rows;
  int columns;
  final List<List<String>> _cells;
  final List<List<List<String>>> _undoStack = [];
  final List<List<List<String>>> _redoStack = [];

  List<List<String>> get rawCells => _cells;

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void snapshot() {
    _undoStack.add(_clone(_cells));
    _redoStack.clear();
  }

  bool undo() {
    if (!canUndo) return false;
    _redoStack.add(_clone(_cells));
    final prev = _undoStack.removeLast();
    _replaceWith(prev);
    return true;
  }

  bool redo() {
    if (!canRedo) return false;
    _undoStack.add(_clone(_cells));
    final next = _redoStack.removeLast();
    _replaceWith(next);
    return true;
  }

  bool deleteRow(int rowIndex) {
    if (rows <= 1 || rowIndex < 0 || rowIndex >= rows) return false;
    _cells.removeAt(rowIndex);
    rows -= 1;
    return true;
  }

  bool deleteColumn(int colIndex) {
    if (columns <= 1 || colIndex < 0 || colIndex >= columns) return false;
    for (final row in _cells) {
      row.removeAt(colIndex);
    }
    columns -= 1;
    return true;
  }

  String valueAt(int row, int col) => _cells[row][col];

  void setValue(int row, int col, String value) {
    _cells[row][col] = value;
  }

  void fillDown({required int fromRow, required int toRow, required int col}) {
    if (fromRow < 0 || fromRow >= rows || toRow < 0 || toRow >= rows || col < 0 || col >= columns) return;
    final source = _cells[fromRow][col];
    for (var r = fromRow + 1; r <= toRow; r++) {
      _cells[r][col] = source;
    }
  }

  void sortByColumn({required int col, bool ascending = true, bool hasHeader = true}) {
    if (col < 0 || col >= columns || rows <= 1) return;
    final start = hasHeader ? 1 : 0;
    final sortable = _cells.sublist(start);

    sortable.sort((a, b) {
      final av = a[col];
      final bv = b[col];
      final an = double.tryParse(av);
      final bn = double.tryParse(bv);
      int cmp;
      if (an != null && bn != null) {
        cmp = an.compareTo(bn);
      } else {
        cmp = av.toLowerCase().compareTo(bv.toLowerCase());
      }
      return ascending ? cmp : -cmp;
    });

    _cells
      ..removeRange(start, _cells.length)
      ..addAll(sortable);
  }

  void addRow() {
    _cells.add(List.generate(columns, (_) => ''));
    rows += 1;
  }

  void addColumn() {
    for (final row in _cells) {
      row.add('');
    }
    columns += 1;
  }

  ({double? min, double? max, double? avg, int count}) columnStats(int col, {bool skipHeader = true}) {
    if (col < 0 || col >= columns) return (min: null, max: null, avg: null, count: 0);
    final start = skipHeader ? 1 : 0;
    double? min;
    double? max;
    double total = 0;
    int count = 0;

    for (var r = start; r < rows; r++) {
      final val = double.tryParse(_cells[r][col]);
      if (val == null) continue;
      min = min == null ? val : (val < min ? val : min);
      max = max == null ? val : (val > max ? val : max);
      total += val;
      count += 1;
    }

    final avg = count == 0 ? null : total / count;
    return (min: min, max: max, avg: avg, count: count);
  }

  List<(int, int)> findMatches(String query, {bool caseSensitive = false}) {
    final q = caseSensitive ? query : query.toLowerCase();
    if (q.trim().isEmpty) return [];

    final matches = <(int, int)>[];
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < columns; c++) {
        final cell = caseSensitive ? _cells[r][c] : _cells[r][c].toLowerCase();
        if (cell.contains(q)) {
          matches.add((r, c));
        }
      }
    }
    return matches;
  }

  int replaceAll(String findText, String replaceText, {bool caseSensitive = false}) {
    final q = caseSensitive ? findText : findText.toLowerCase();
    if (q.trim().isEmpty) return 0;

    int replaced = 0;
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < columns; c++) {
        final source = _cells[r][c];
        final probe = caseSensitive ? source : source.toLowerCase();
        if (probe.contains(q)) {
          if (caseSensitive) {
            _cells[r][c] = source.replaceAll(findText, replaceText);
          } else {
            _cells[r][c] = _replaceCaseInsensitive(source, findText, replaceText);
          }
          replaced += 1;
        }
      }
    }
    return replaced;
  }

  String resolvedValue(int row, int col) {
    final source = _cells[row][col].trim();
    if (!source.startsWith('=')) return source;

    final formula = source.substring(1).toUpperCase().trim();

    if (formula.startsWith('SUM(') && formula.endsWith(')')) {
      final expr = formula.substring(4, formula.length - 1);
      return _rangeAggregate(expr, average: false);
    }

    if (formula.startsWith('AVG(') && formula.endsWith(')')) {
      final expr = formula.substring(4, formula.length - 1);
      return _rangeAggregate(expr, average: true);
    }

    if (formula.startsWith('MIN(') && formula.endsWith(')')) {
      final expr = formula.substring(4, formula.length - 1);
      return _rangeMinMax(expr, minMode: true);
    }

    if (formula.startsWith('MAX(') && formula.endsWith(')')) {
      final expr = formula.substring(4, formula.length - 1);
      return _rangeMinMax(expr, minMode: false);
    }

    final ref = _cellFromRef(formula);
    if (ref != null) {
      return _safeRawValue(ref.$1, ref.$2);
    }

    return '#N/A';
  }

  String _rangeAggregate(String expr, {required bool average}) {
    final coords = _rangeBounds(expr);
    if (coords == null) return '#ERR';
    final (minRow, maxRow, minCol, maxCol) = coords;

    double total = 0;
    var count = 0;
    for (var r = minRow; r <= maxRow; r++) {
      for (var c = minCol; c <= maxCol; c++) {
        if (r < 0 || r >= rows || c < 0 || c >= columns) continue;
        total += double.tryParse(_safeRawValue(r, c)) ?? 0;
        count += 1;
      }
    }

    if (average) {
      if (count == 0) return '0';
      final avg = total / count;
      return avg.toStringAsFixed(avg.truncateToDouble() == avg ? 0 : 2);
    }

    return total.toStringAsFixed(total.truncateToDouble() == total ? 0 : 2);
  }

  String _rangeMinMax(String expr, {required bool minMode}) {
    final coords = _rangeBounds(expr);
    if (coords == null) return '#ERR';
    final (minRow, maxRow, minCol, maxCol) = coords;

    double? best;
    for (var r = minRow; r <= maxRow; r++) {
      for (var c = minCol; c <= maxCol; c++) {
        if (r < 0 || r >= rows || c < 0 || c >= columns) continue;
        final val = double.tryParse(_safeRawValue(r, c));
        if (val == null) continue;
        if (best == null) {
          best = val;
        } else if (minMode && val < best) {
          best = val;
        } else if (!minMode && val > best) {
          best = val;
        }
      }
    }

    if (best == null) return '0';
    return best.toStringAsFixed(best.truncateToDouble() == best ? 0 : 2);
  }

  (int, int, int, int)? _rangeBounds(String expr) {
    final parts = expr.split(':');
    if (parts.length != 2) return null;
    final a = _cellFromRef(parts[0]);
    final b = _cellFromRef(parts[1]);
    if (a == null || b == null) return null;

    final minRow = a.$1 < b.$1 ? a.$1 : b.$1;
    final maxRow = a.$1 > b.$1 ? a.$1 : b.$1;
    final minCol = a.$2 < b.$2 ? a.$2 : b.$2;
    final maxCol = a.$2 > b.$2 ? a.$2 : b.$2;
    return (minRow, maxRow, minCol, maxCol);
  }

  String _safeRawValue(int row, int col) {
    if (row < 0 || row >= rows || col < 0 || col >= columns) return '';
    return _cells[row][col];
  }

  (int, int)? _cellFromRef(String ref) {
    final clean = ref.trim();
    final match = RegExp(r'^([A-Z]+)(\d+)$').firstMatch(clean);
    if (match == null) return null;

    final colRef = match.group(1)!;
    final rowRef = int.tryParse(match.group(2)!);
    if (rowRef == null) return null;

    var col = 0;
    for (final code in colRef.codeUnits) {
      col = col * 26 + (code - 64);
    }
    return (rowRef - 1, col - 1);
  }

  String _replaceCaseInsensitive(String source, String find, String replace) {
    final escaped = RegExp.escape(find);
    return source.replaceAll(RegExp(escaped, caseSensitive: false), replace);
  }

  List<List<String>> _clone(List<List<String>> matrix) => matrix.map((r) => List<String>.from(r)).toList();

  void _replaceWith(List<List<String>> matrix) {
    _cells
      ..clear()
      ..addAll(_clone(matrix));
    rows = _cells.length;
    columns = _cells.isEmpty ? 0 : _cells.first.length;
  }
}
