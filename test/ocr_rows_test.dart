import 'package:flutter_test/flutter_test.dart';
import 'package:komposisiku/label_parser.dart';
import 'package:komposisiku/ocr_rows.dart';

void main() {
  test('menyatukan kolom zat gizi, jumlah, dan AKG menurut posisi', () {
    final rows = nutritionRows([
      const OcrSegment('90 mg', 150, 41, 12),
      const OcrSegment('Gula total', 10, 20, 12),
      const OcrSegment('6%', 210, 40, 12),
      const OcrSegment('12 g', 150, 21, 12),
      const OcrSegment('Natrium', 10, 40, 12),
    ]);
    expect(rows, 'Gula total 12 g\nNatrium 90 mg 6%');
    final label = NutritionLabel.parse(rows);
    expect(label.nutrients, hasLength(2));
    expect(label.nutrients[1].dailyPercent, 6);
  });
  test('baris yang terpisah tidak digabung dan teks kosong diabaikan', () {
    expect(
        nutritionRows([
          const OcrSegment('', 1, 0, 10),
          const OcrSegment('Gula', 1, 15, 10),
          const OcrSegment('Natrium', 1, 35, 10),
        ]),
        'Gula\nNatrium');
  });
}
