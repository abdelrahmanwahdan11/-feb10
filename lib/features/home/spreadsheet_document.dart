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

  int removeFullyEmptyRows({bool keepHeader = true}) {
    var removed = 0;
    final start = keepHeader ? 1 : 0;
    for (var r = rows - 1; r >= start; r--) {
      if (_rowIsEmpty(r)) {
        _cells.removeAt(r);
        rows -= 1;
        removed += 1;
      }
    }
    return removed;
  }

  int removeFullyEmptyColumns({bool keepFirstColumn = false}) {
    var removed = 0;
    final start = keepFirstColumn ? 1 : 0;
    for (var c = columns - 1; c >= start; c--) {
      if (_columnIsEmpty(c)) {
        for (final row in _cells) {
          row.removeAt(c);
        }
        columns -= 1;
        removed += 1;
      }
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

  ({double? median, double? stdev, double? variance, double sum, int count}) columnAdvancedStats(
    int col, {
    bool skipHeader = true,
  }) {
    if (col < 0 || col >= columns) return (median: null, stdev: null, variance: null, sum: 0, count: 0);
    final values = <double>[];
    final start = skipHeader ? 1 : 0;
    for (var r = start; r < rows; r++) {
      final val = double.tryParse(_cells[r][col]);
      if (val != null) values.add(val);
    }
    if (values.isEmpty) return (median: null, stdev: null, variance: null, sum: 0, count: 0);

    values.sort();
    final mid = values.length ~/ 2;
    final median = values.length.isOdd ? values[mid] : (values[mid - 1] + values[mid]) / 2;
    final sum = values.fold<double>(0, (acc, v) => acc + v);
    final mean = sum / values.length;
    var variance = 0.0;
    for (final v in values) {
      final d = v - mean;
      variance += d * d;
    }
    variance /= values.length;
    final stdev = variance <= 0 ? 0.0 : _sqrt(variance);

    return (median: median, stdev: stdev, variance: variance, sum: sum, count: values.length);
  }

  int normalizeColumnZScore(int col, {bool skipHeader = true}) {
    final stats = columnAdvancedStats(col, skipHeader: skipHeader);
    if (stats.count == 0 || stats.stdev == null || stats.stdev == 0) return 0;

    final mean = stats.sum / stats.count;
    final start = skipHeader ? 1 : 0;
    var updated = 0;
    for (var r = start; r < rows; r++) {
      final v = double.tryParse(_cells[r][col]);
      if (v == null) continue;
      final z = (v - mean) / stats.stdev!;
      _cells[r][col] = z.toStringAsFixed(3);
      updated += 1;
    }
    return updated;
  }

  List<int> detectOutlierRowsIqr(int col, {bool skipHeader = true, double factor = 1.5}) {
    final start = skipHeader ? 1 : 0;
    final pairs = <(int, double)>[];
    for (var r = start; r < rows; r++) {
      final v = double.tryParse(_cells[r][col]);
      if (v != null) pairs.add((r, v));
    }
    if (pairs.length < 4) return [];

    final sorted = pairs.map((e) => e.$2).toList()..sort();
    final q1 = _percentile(sorted, 0.25);
    final q3 = _percentile(sorted, 0.75);
    final iqr = q3 - q1;
    final low = q1 - factor * iqr;
    final high = q3 + factor * iqr;

    final rowsOut = <int>[];
    for (final item in pairs) {
      if (item.$2 < low || item.$2 > high) rowsOut.add(item.$1);
    }
    return rowsOut;
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

    if (upperFormula.startsWith('STDEV(') && upperFormula.endsWith(')')) {
      final expr = upperFormula.substring(6, upperFormula.length - 1);
      final result = _rangeDispersion(expr, visiting: visiting, varianceMode: false);
      visiting.remove(key);
      return result;
    }

    if (upperFormula.startsWith('VAR(') && upperFormula.endsWith(')')) {
      final expr = upperFormula.substring(4, upperFormula.length - 1);
      final result = _rangeDispersion(expr, visiting: visiting, varianceMode: true);
      visiting.remove(key);
      return result;
    }

    if (upperFormula.startsWith('PCTL(') && upperFormula.endsWith(')')) {
      final args = _splitTopLevelArgs(formulaText.substring(5, formulaText.length - 1));
      if (args.length == 2) {
        final result = _rangePercentile(args[0], args[1], visiting: visiting);
        visiting.remove(key);
        return result;
      }
      visiting.remove(key);
      return '#ERR';
    }

    if (upperFormula.startsWith('RANK(') && upperFormula.endsWith(')')) {
      final args = _splitTopLevelArgs(formulaText.substring(5, formulaText.length - 1));
      if (args.length == 2) {
        final result = _rangeRank(args[0], args[1], visiting: visiting);
        visiting.remove(key);
        return result;
      }
      visiting.remove(key);
      return '#ERR';
    }

    if (upperFormula.startsWith('IF(') && upperFormula.endsWith(')')) {
      final args = _splitTopLevelArgs(formulaText.substring(3, formulaText.length - 1));
      if (args.length == 3) {
        final condition = _evaluateCondition(args[0], visiting: visiting);
        final branch = condition ? args[1].trim() : args[2].trim();
        if (branch.startsWith('"') && branch.endsWith('"') && branch.length >= 2) {
          visiting.remove(key);
          return branch.substring(1, branch.length - 1);
        }
        final branchNumber = _evaluateExpression(branch, visiting: visiting);
        if (branchNumber != null) {
          final result = branchNumber.toStringAsFixed(branchNumber.truncateToDouble() == branchNumber ? 0 : 2);
          visiting.remove(key);
          return result;
        }
        if (branch.toUpperCase().startsWith('=') || RegExp(r'^[A-Za-z]+\d+$').hasMatch(branch)) {
          final clean = branch.startsWith('=') ? branch.substring(1) : branch;
          final cell = _cellFromRef(clean.toUpperCase());
          if (cell != null) {
            final result = resolvedValue(cell.$1, cell.$2, _visiting: visiting);
            visiting.remove(key);
            return result;
          }
        }
        visiting.remove(key);
        return branch;
      }
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

  String _rangeDispersion(String expr, {required Set<String> visiting, required bool varianceMode}) {
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

    final sum = values.fold<double>(0, (acc, v) => acc + v);
    final mean = sum / values.length;
    var variance = 0.0;
    for (final v in values) {
      final d = v - mean;
      variance += d * d;
    }
    variance /= values.length;

    final out = varianceMode ? variance : (variance <= 0 ? 0.0 : _sqrt(variance));
    return out.toStringAsFixed(out.truncateToDouble() == out ? 0 : 2);
  }

  String _rangePercentile(String rangeExpr, String percentileExpr, {required Set<String> visiting}) {
    final values = _rangeValues(rangeExpr, visiting: visiting);
    if (values.isEmpty) return '0';

    final p = _evaluateExpression(percentileExpr, visiting: visiting);
    if (p == null) return '#ERR';
    final clamped = p < 0 ? 0.0 : (p > 1 ? 1.0 : p);

    values.sort();
    if (values.length == 1) return values.first.toStringAsFixed(values.first.truncateToDouble() == values.first ? 0 : 2);

    final pos = clamped * (values.length - 1);
    final lower = pos.floor();
    final upper = pos.ceil();
    if (lower == upper) {
      final out = values[lower];
      return out.toStringAsFixed(out.truncateToDouble() == out ? 0 : 2);
    }
    final fraction = pos - lower;
    final out = values[lower] + (values[upper] - values[lower]) * fraction;
    return out.toStringAsFixed(out.truncateToDouble() == out ? 0 : 2);
  }

  String _rangeRank(String valueExpr, String rangeExpr, {required Set<String> visiting}) {
    final values = _rangeValues(rangeExpr, visiting: visiting);
    if (values.isEmpty) return '0';

    final target = _evaluateExpression(valueExpr, visiting: visiting);
    if (target == null) return '#ERR';

    values.sort((a, b) => b.compareTo(a));
    for (var i = 0; i < values.length; i++) {
      if (values[i] == target) return '${i + 1}';
    }

    var rank = 1;
    for (final v in values) {
      if (v > target) {
        rank += 1;
      }
    }
    return '$rank';
  }

  List<double> _rangeValues(String expr, {required Set<String> visiting}) {
    final coords = _rangeBounds(expr.toUpperCase());
    if (coords == null) return [];
    final (minRow, maxRow, minCol, maxCol) = coords;
    final values = <double>[];
    for (var r = minRow; r <= maxRow; r++) {
      for (var c = minCol; c <= maxCol; c++) {
        if (r < 0 || r >= rows || c < 0 || c >= columns) continue;
        final v = _numericCellValue(r, c, visiting);
        if (v != null) values.add(v);
      }
    }
    return values;
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

  double _percentile(List<double> sorted, double p) {
    if (sorted.isEmpty) return 0;
    if (p <= 0) return sorted.first;
    if (p >= 1) return sorted.last;
    final pos = p * (sorted.length - 1);
    final lo = pos.floor();
    final hi = pos.ceil();
    if (lo == hi) return sorted[lo];
    final f = pos - lo;
    return sorted[lo] + (sorted[hi] - sorted[lo]) * f;
  }

  double _sqrt(double value) {
    if (value <= 0) return 0;
    var x = value;
    for (var i = 0; i < 12; i++) {
      x = 0.5 * (x + value / x);
    }
    return x;
  }

  bool _evaluateCondition(String expr, {required Set<String> visiting}) {
    final ops = ['>=', '<=', '==', '!=', '>', '<'];
    for (final op in ops) {
      final idx = expr.indexOf(op);
      if (idx <= 0) continue;
      final left = expr.substring(0, idx).trim();
      final right = expr.substring(idx + op.length).trim();
      final lv = _evaluateExpression(left, visiting: visiting);
      final rv = _evaluateExpression(right, visiting: visiting);
      if (lv == null || rv == null) return false;
      switch (op) {
        case '>=':
          return lv >= rv;
        case '<=':
          return lv <= rv;
        case '==':
          return lv == rv;
        case '!=':
          return lv != rv;
        case '>':
          return lv > rv;
        case '<':
          return lv < rv;
      }
    }
    final raw = expr.trim().toLowerCase();
    if (raw == 'true') return true;
    if (raw == 'false') return false;
    final n = _evaluateExpression(expr, visiting: visiting);
    return (n ?? 0) != 0;
  }

  List<String> _splitTopLevelArgs(String input) {
    final parts = <String>[];
    var depth = 0;
    var inString = false;
    var start = 0;
    for (var i = 0; i < input.length; i++) {
      final ch = input[i];
      if (ch == '"') {
        inString = !inString;
      }
      if (inString) continue;
      if (ch == '(') depth++;
      if (ch == ')') depth--;
      if (ch == ',' && depth == 0) {
        parts.add(input.substring(start, i).trim());
        start = i + 1;
      }
    }
    parts.add(input.substring(start).trim());
    return parts;
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
