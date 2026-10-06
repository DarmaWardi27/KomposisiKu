import 'package:flutter_test/flutter_test.dart';
import 'package:komposisiku/label_parser.dart';

void main() {
  test('mempertahankan campuran dalam kurung sebagai satu bahan', () {
    expect(
      parseIngredients('Komposisi: tepung terigu, premiks (gula, garam), air'),
      ['tepung terigu', 'premiks (gula, garam)', 'air'],
    );
  });
  test('membaca koma desimal, unit mg, dan persen AKG', () {
    final label = NutritionLabel.parse(
      'Takaran saji 30 g\nLemak total 2,5 g 4%\nNatrium 90 mg 6%\nGula total 12 g',
    );
    expect(label.serving, '30 g');
    expect(label.nutrients, hasLength(3));
    expect(label.nutrients.first.amount, 2.5);
    expect(label.nutrients[1].unit, 'mg');
    expect(label.nutrients[1].dailyPercent, 6);
    expect(label.nutrients.last.dailyPercent, isNull);
  });
  test('tidak mengisi data kosong dengan nol', () {
    final label = NutritionLabel.parse('Gula total tidak terbaca');
    expect(label.nutrients, isEmpty);
    expect(label.serving, isNull);
  });
  test('tidak menyamakan bahan tak dikenal dengan bahan kamus', () {
    expect(ingredientInfo('gula kelapa'), contains('belum ada'));
    expect(ingredientInfo('tepung terigu (20%)'), contains('gluten'));
  });
}
