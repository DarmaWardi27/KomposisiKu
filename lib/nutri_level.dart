enum Sweetener { none, natural, artificial }

class NutriAssessment {
  const NutriAssessment(
    this.sugar,
    this.sodium,
    this.saturatedFat,
    this.componentGrades,
    this.grade,
  );
  final double sugar;
  final double sodium;
  final double saturatedFat;
  final List<int> componentGrades;
  final int grade;
  String get letter => 'ABCD'[grade];
}

/// KMK 301/2026 lampiran A (halaman 5–7).
/// Input per saji; natrium dalam mg. Hanya minuman olahan siap saji.
NutriAssessment assessDrink({
  required double servingMl,
  required double sugarGrams,
  required double sodiumMg,
  required double saturatedFatGrams,
  required Sweetener sweetener,
  double lactoseGrams = 0,
}) {
  final values = [
    servingMl,
    sugarGrams,
    sodiumMg,
    saturatedFatGrams,
    lactoseGrams,
  ];
  if (values.any((v) => !v.isFinite || v < 0) ||
      servingMl == 0 ||
      lactoseGrams > sugarGrams) {
    throw ArgumentError(
      'Periksa takaran saji dan angka gizi; laktosa tidak boleh lebih besar dari gula total.',
    );
  }
  final sugar =
      (((sugarGrams - lactoseGrams) * 100 / servingMl) * 10).round() / 10;
  final sodium = sodiumMg * 100 / servingMl;
  final saturated = saturatedFatGrams * 100 / servingMl;
  int threshold(double value, List<double> limits) {
    for (var i = 0; i < limits.length; i++) {
      if (value <= limits[i]) return i;
    }
    return 3;
  }

  final grades = [
    threshold(sugar, [1, 5, 10]),
    threshold(sodium, [5, 120, 500]),
    threshold(saturated, [0.7, 1.2, 2.8]),
  ];
  var grade = grades.reduce((a, b) => a > b ? a : b);
  // Lampiran A angka 2–4: A tanpa BTP pemanis, B hanya BTP pemanis alami.
  final minimum = sweetener == Sweetener.artificial
      ? 2
      : sweetener == Sweetener.natural
          ? 1
          : 0;
  if (grade < minimum) grade = minimum;
  return NutriAssessment(sugar, sodium, saturated, grades, grade);
}
