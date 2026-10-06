/// A text line and its position on the photographed label.
class OcrSegment {
  const OcrSegment(this.text, this.left, this.top, this.height);
  final String text;
  final double left;
  final double top;
  final double height;
  double get center => top + height / 2;
}

/// Joins separate label/amount/%AKG columns that OCR found on the same row.
/// The result still requires user review; skewed/wrapped labels can be ambiguous.
String nutritionRows(List<OcrSegment> segments) {
  final sorted = [...segments]..sort((a, b) => a.center.compareTo(b.center));
  final rows = <List<OcrSegment>>[];
  for (final segment in sorted) {
    if (segment.text.trim().isEmpty) continue;
    List<OcrSegment>? target;
    for (final row in rows.reversed) {
      final anchor = row.first;
      final smallerHeight =
          segment.height < anchor.height ? segment.height : anchor.height;
      if ((segment.center - anchor.center).abs() <= smallerHeight * 0.45) {
        target = row;
        break;
      }
    }
    if (target == null) {
      rows.add([segment]);
    } else {
      target.add(segment);
    }
  }
  return rows.map((row) {
    row.sort((a, b) => a.left.compareTo(b.left));
    return row.map((segment) => segment.text.trim()).join(' ');
  }).join('\n');
}
