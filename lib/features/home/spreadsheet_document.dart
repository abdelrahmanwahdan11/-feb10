class SpreadsheetDocument {
  SpreadsheetDocument({this.rows = 20, this.columns = 10})
      : _cells = List.generate(rows, (_) => List.generate(columns, (_) => ''));

  int rows;
  int columns;
  final List<List<String>> _cells;

  List<List<String>> get rawCells => _cells;

  String valueAt(int row, int col) => _cells[row][col];

  void setValue(int row, int col, String value) {
    _cells[row][col] = value;
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

    final ref = _cellFromRef(formula);
    if (ref != null) {
      return _safeRawValue(ref.$1, ref.$2);
    }

    return '#N/A';
  }

  String _rangeAggregate(String expr, {required bool average}) {
    final parts = expr.split(':');
    if (parts.length != 2) return '#ERR';
    final a = _cellFromRef(parts[0]);
    final b = _cellFromRef(parts[1]);
    if (a == null || b == null) return '#ERR';

    final minRow = a.$1 < b.$1 ? a.$1 : b.$1;
    final maxRow = a.$1 > b.$1 ? a.$1 : b.$1;
    final minCol = a.$2 < b.$2 ? a.$2 : b.$2;
    final maxCol = a.$2 > b.$2 ? a.$2 : b.$2;

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
}
