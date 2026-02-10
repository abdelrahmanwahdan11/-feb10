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

  bool insertRow(int rowIndex) {
    if (rowIndex < 0 || rowIndex > rows) return false;
    _cells.insert(rowIndex, List.generate(columns, (_) => ''));
    rows += 1;
    return true;
  }

  bool insertColumn(int colIndex) {
    if (colIndex < 0 || colIndex > columns) return false;
    for (final row in _cells) {
      row.insert(colIndex, '');
    }
    columns += 1;
    return true;
  }

  void ensureSize({required int minRows, required int minColumns}) {
    while (rows < minRows) {
      addRow();
    }
    while (columns < minColumns) {
      addColumn();
    }
  }

  int trimTrailingEmpty({int keepAtLeastRows = 1, int keepAtLeastColumns = 1}) {
    var removed = 0;

    while (rows > keepAtLeastRows && _rowIsEmpty(rows - 1)) {
      _cells.removeLast();
      rows -= 1;
      removed += 1;
    }

    while (columns > keepAtLeastColumns && _columnIsEmpty(columns - 1)) {
      for (final row in _cells) {
        row.removeLast();
      }
      columns -= 1;
      removed += 1;
    }

    return removed;
  }

  List<String> formulaDiagnostics() {
    final issues = <String>[];
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < columns; c++) {
        final raw = _cells[r][c].trim();
        if (!raw.startsWith('=')) continue;
        final resolved = resolvedValue(r, c);
        if (resolved.startsWith('#')) {
          issues.add('${_colName(c)}${r + 1}: $resolved');
        }
      }
    }
    return issues;
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

  String resolvedValue(int row, int col, {Set<String>? _visiting}) {
    if (row < 0 || row >= rows || col < 0 || col >= columns) return '';
    final visiting = _visiting ?? <String>{};
    final key = '$row:$col';
    if (visiting.contains(key)) return '#CYCLE';

    visiting.add(key);
    final source = _cells[row][col].trim();
    if (!source.startsWith('=')) {
      visiting.remove(key);
      return source;
    }

    final formulaText = source.substring(1).trim();
    final upperFormula = formulaText.toUpperCase();

    if (upperFormula.startsWith('SUM(') && upperFormula.endsWith(')')) {
      final expr = upperFormula.substring(4, upperFormula.length - 1);
      final result = _rangeAggregate(expr, average: false, visiting: visiting);
      visiting.remove(key);
      return result;
    }

    if (upperFormula.startsWith('AVG(') && upperFormula.endsWith(')')) {
      final expr = upperFormula.substring(4, upperFormula.length - 1);
      final result = _rangeAggregate(expr, average: true, visiting: visiting);
      visiting.remove(key);
      return result;
    }

    if (upperFormula.startsWith('MIN(') && upperFormula.endsWith(')')) {
      final expr = upperFormula.substring(4, upperFormula.length - 1);
      final result = _rangeMinMax(expr, minMode: true, visiting: visiting);
      visiting.remove(key);
      return result;
    }

    if (upperFormula.startsWith('MAX(') && upperFormula.endsWith(')')) {
      final expr = upperFormula.substring(4, upperFormula.length - 1);
      final result = _rangeMinMax(expr, minMode: false, visiting: visiting);
      visiting.remove(key);
      return result;
    }

    if (upperFormula.startsWith('COUNT(') && upperFormula.endsWith(')')) {
      final expr = upperFormula.substring(6, upperFormula.length - 1);
      final result = _rangeCount(expr, visiting: visiting);
      visiting.remove(key);
      return result;
    }

    if (upperFormula.startsWith('MEDIAN(') && upperFormula.endsWith(')')) {
      final expr = upperFormula.substring(7, upperFormula.length - 1);
      final result = _rangeMedian(expr, visiting: visiting);
      visiting.remove(key);
      return result;
    }

    final ref = _cellFromRef(upperFormula);
    if (ref != null) {
      final result = resolvedValue(ref.$1, ref.$2, _visiting: visiting);
      visiting.remove(key);
      return result;
    }

    final arithmetic = _evaluateExpression(formulaText, visiting: visiting);
    if (arithmetic != null) {
      final result = arithmetic.toStringAsFixed(arithmetic.truncateToDouble() == arithmetic ? 0 : 2);
      visiting.remove(key);
      return result;
    }

    visiting.remove(key);
    return '#N/A';
  }

  String _rangeAggregate(String expr, {required bool average, required Set<String> visiting}) {
    final coords = _rangeBounds(expr);
    if (coords == null) return '#ERR';
    final (minRow, maxRow, minCol, maxCol) = coords;

    double total = 0;
    var count = 0;
    for (var r = minRow; r <= maxRow; r++) {
      for (var c = minCol; c <= maxCol; c++) {
        if (r < 0 || r >= rows || c < 0 || c >= columns) continue;
        total += _numericCellValue(r, c, visiting) ?? 0;
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

  String _rangeMinMax(String expr, {required bool minMode, required Set<String> visiting}) {
    final coords = _rangeBounds(expr);
    if (coords == null) return '#ERR';
    final (minRow, maxRow, minCol, maxCol) = coords;

    double? best;
    for (var r = minRow; r <= maxRow; r++) {
      for (var c = minCol; c <= maxCol; c++) {
        if (r < 0 || r >= rows || c < 0 || c >= columns) continue;
        final val = _numericCellValue(r, c, visiting);
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

  String _rangeCount(String expr, {required Set<String> visiting}) {
    final coords = _rangeBounds(expr);
    if (coords == null) return '#ERR';
    final (minRow, maxRow, minCol, maxCol) = coords;

    var count = 0;
    for (var r = minRow; r <= maxRow; r++) {
      for (var c = minCol; c <= maxCol; c++) {
        if (r < 0 || r >= rows || c < 0 || c >= columns) continue;
        if (_numericCellValue(r, c, visiting) != null) count += 1;
      }
    }
    return '$count';
  }

  String _rangeMedian(String expr, {required Set<String> visiting}) {
    final coords = _rangeBounds(expr);
    if (coords == null) return '#ERR';
    final (minRow, maxRow, minCol, maxCol) = coords;

    final values = <double>[];
    for (var r = minRow; r <= maxRow; r++) {
      for (var c = minCol; c <= maxCol; c++) {
        if (r < 0 || r >= rows || c < 0 || c >= columns) continue;
        final v = _numericCellValue(r, c, visiting);
        if (v != null) values.add(v);
      }
    }
    if (values.isEmpty) return '0';

    values.sort();
    final mid = values.length ~/ 2;
    final median = values.length.isOdd ? values[mid] : (values[mid - 1] + values[mid]) / 2;
    return median.toStringAsFixed(median.truncateToDouble() == median ? 0 : 2);
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

  bool _rowIsEmpty(int rowIndex) => _cells[rowIndex].every((cell) => cell.trim().isEmpty);

  bool _columnIsEmpty(int colIndex) {
    for (final row in _cells) {
      if (row[colIndex].trim().isNotEmpty) return false;
    }
    return true;
  }

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

  double? _numericCellValue(int row, int col, Set<String> visiting) {
    final value = resolvedValue(row, col, _visiting: Set<String>.from(visiting));
    return double.tryParse(value);
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

  double? _evaluateExpression(String expr, {required Set<String> visiting}) {
    final parser = _ExpressionParser(
      expr,
      resolveReference: (ref) {
        final cell = _cellFromRef(ref.toUpperCase());
        if (cell == null) return null;
        return _numericCellValue(cell.$1, cell.$2, visiting);
      },
    );
    return parser.parse();
  }
}

class _ExpressionParser {
  _ExpressionParser(this._source, {required this.resolveReference});

  final String _source;
  final double? Function(String ref) resolveReference;
  int _index = 0;

  double? parse() {
    final value = _parseExpression();
    _skipWhitespace();
    if (value == null || _index != _source.length) return null;
    return value;
  }

  double? _parseExpression() {
    var left = _parseTerm();
    if (left == null) return null;

    while (true) {
      _skipWhitespace();
      if (_match('+')) {
        final right = _parseTerm();
        if (right == null) return null;
        left += right;
      } else if (_match('-')) {
        final right = _parseTerm();
        if (right == null) return null;
        left -= right;
      } else {
        break;
      }
    }

    return left;
  }

  double? _parseTerm() {
    var left = _parseFactor();
    if (left == null) return null;

    while (true) {
      _skipWhitespace();
      if (_match('*')) {
        final right = _parseFactor();
        if (right == null) return null;
        left *= right;
      } else if (_match('/')) {
        final right = _parseFactor();
        if (right == null || right == 0) return null;
        left /= right;
      } else {
        break;
      }
    }
    return left;
  }

  double? _parseFactor() {
    _skipWhitespace();

    if (_match('+')) return _parseFactor();
    if (_match('-')) {
      final value = _parseFactor();
      return value == null ? null : -value;
    }

    if (_match('(')) {
      final value = _parseExpression();
      _skipWhitespace();
      if (!_match(')')) return null;
      return value;
    }

    final number = _parseNumber();
    if (number != null) return number;

    final reference = _parseReference();
    if (reference != null) return resolveReference(reference);

    return null;
  }

  double? _parseNumber() {
    _skipWhitespace();
    final start = _index;
    var sawDigit = false;
    var sawDot = false;
    while (_index < _source.length) {
      final ch = _source[_index];
      final isDigit = ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;
      if (isDigit) {
        sawDigit = true;
        _index++;
      } else if (ch == '.' && !sawDot) {
        sawDot = true;
        _index++;
      } else {
        break;
      }
    }

    if (!sawDigit) {
      _index = start;
      return null;
    }
    return double.tryParse(_source.substring(start, _index));
  }

  String? _parseReference() {
    _skipWhitespace();
    final start = _index;
    while (_index < _source.length && _isLetter(_source[_index])) {
      _index++;
    }
    if (_index == start) return null;

    final digitsStart = _index;
    while (_index < _source.length && _isDigit(_source[_index])) {
      _index++;
    }
    if (_index == digitsStart) {
      _index = start;
      return null;
    }
    return _source.substring(start, _index);
  }

  bool _isLetter(String ch) {
    final code = ch.toUpperCase().codeUnitAt(0);
    return code >= 65 && code <= 90;
  }

  bool _isDigit(String ch) {
    final code = ch.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }

  bool _match(String char) {
    if (_index < _source.length && _source[_index] == char) {
      _index++;
      return true;
    }
    return false;
  }

  void _skipWhitespace() {
    while (_index < _source.length && _source[_index].trim().isEmpty) {
      _index++;
    }
  }
}
