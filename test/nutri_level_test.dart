import 'package:flutter_test/flutter_test.dart';
import 'package:komposisiku/nutri_level.dart';

void main() {
  NutriAssessment assess(
    double sugar, {
    double sodium = 0,
    double fat = 0,
    Sweetener sweetener = Sweetener.none,
  }) =>
      assessDrink(
        servingMl: 100,
        sugarGrams: sugar,
        sodiumMg: sodium,
        saturatedFatGrams: fat,
        sweetener: sweetener,
      );
  test('batas gula dan pembulatan contoh resmi 5,01 menjadi B', () {
    expect(assess(1).letter, 'A');
    expect(assess(1.1).letter, 'B');
    expect(assess(5.01).letter, 'B');
    expect(assess(5.1).letter, 'C');
    expect(assess(10).letter, 'C');
    expect(assess(10.1).letter, 'D');
  });
  test('normalisasi contoh gula dan laktosa 19-4 per 250 ml', () {
    final result = assessDrink(
      servingMl: 250,
      sugarGrams: 19,
      lactoseGrams: 4,
      sodiumMg: 0,
      saturatedFatGrams: 0,
      sweetener: Sweetener.none,
    );
    expect(result.sugar, 6);
    expect(result.letter, 'C');
  });
  test('batas natrium dan lemak jenuh', () {
    expect(assess(0, sodium: 5).letter, 'A');
    expect(assess(0, sodium: 120).letter, 'B');
    expect(assess(0, sodium: 500).letter, 'C');
    expect(assess(0, sodium: 501).letter, 'D');
    expect(assess(0, fat: 0.7).letter, 'A');
    expect(assess(0, fat: 1.2).letter, 'B');
    expect(assess(0, fat: 2.8).letter, 'C');
    expect(assess(0, fat: 2.81).letter, 'D');
  });
  test('BTP pemanis membatasi kelayakan A dan B', () {
    expect(assess(0, sweetener: Sweetener.natural).letter, 'B');
    expect(assess(0, sweetener: Sweetener.artificial).letter, 'C');
  });
  test('data tidak valid ditolak', () {
    expect(() => assess(-1), throwsArgumentError);
    expect(() => assess(double.nan), throwsArgumentError);
    expect(
      () => assessDrink(
        servingMl: 0,
        sugarGrams: 1,
        sodiumMg: 0,
        saturatedFatGrams: 0,
        sweetener: Sweetener.none,
      ),
      throwsArgumentError,
    );
    expect(
      () => assessDrink(
        servingMl: 100,
        sugarGrams: 1,
        lactoseGrams: 2,
        sodiumMg: 0,
        saturatedFatGrams: 0,
        sweetener: Sweetener.none,
      ),
      throwsArgumentError,
    );
  });
}
