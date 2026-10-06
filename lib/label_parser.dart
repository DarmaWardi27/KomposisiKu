class Nutrient {
  const Nutrient(this.name, this.amount, this.unit, this.dailyPercent);
  final String name;
  final double amount;
  final String unit;
  final double? dailyPercent;
}

class NutritionLabel {
  const NutritionLabel(this.serving, this.nutrients);
  final String? serving;
  final List<Nutrient> nutrients;
  static NutritionLabel parse(String text) {
    final serving = RegExp(
      r'takaran saji\s*[:\-]?\s*(\d+(?:[.,]\d+)?\s*(?:ml|g)\b)',
      caseSensitive: false,
    ).firstMatch(text)?.group(1);
    final nutrients = <Nutrient>[];
    const names = [
      'Energi total',
      'Lemak total',
      'Lemak jenuh',
      'Protein',
      'Karbohidrat total',
      'Serat pangan',
      'Gula total',
      'Gula',
      'Natrium',
      'Garam',
    ];
    for (final line in text.split('\n')) {
      for (final name in names) {
        final match = RegExp(
          '${RegExp.escape(name)}\\s*[:\\-]?\\s*(\\d+(?:[.,]\\d+)?)\\s*(kkal|kcal|mg|g)\\b(?:\\s+(\\d+(?:[.,]\\d+)?)\\s*%)?',
          caseSensitive: false,
        ).firstMatch(line);
        if (match != null) {
          nutrients.add(
            Nutrient(
              name,
              double.parse(match.group(1)!.replaceAll(',', '.')),
              match.group(2)!.toLowerCase(),
              match.group(3) == null
                  ? null
                  : double.parse(match.group(3)!.replaceAll(',', '.')),
            ),
          );
          break;
        }
      }
    }
    return NutritionLabel(serving, nutrients);
  }
}

List<String> parseIngredients(String text) {
  final body = text.replaceFirst(
    RegExp(r'^\s*komposisi\s*[:\-]?\s*', caseSensitive: false),
    '',
  );
  final result = <String>[];
  var depth = 0;
  var start = 0;
  for (var i = 0; i < body.length; i++) {
    if (body[i] == '(') depth++;
    if (body[i] == ')' && depth > 0) depth--;
    if ((body[i] == ',' || body[i] == ';' || body[i] == '\n') && depth == 0) {
      final part = body.substring(start, i).trim();
      if (part.isNotEmpty) result.add(part);
      start = i + 1;
    }
  }
  final last = body.substring(start).trim();
  if (last.isNotEmpty) result.add(last);
  return result;
}

String ingredientInfo(String ingredient) {
  final key = ingredient
      .toLowerCase()
      .replaceAll(RegExp(r'\s*\([^)]*\)'), '')
      .replaceAll(RegExp(r'\s*\d+[.,]?\d*\s*%'), '')
      .trim();
  const info = {
    'gula':
        'Memberi rasa manis. Jumlah gula pada produk perlu dilihat di Informasi Nilai Gizi; urutan komposisi tidak menunjukkan jumlah gram.',
    'garam':
        'Memberi rasa asin. Periksa natrium pada tabel gizi untuk mengetahui jumlah per sajian.',
    'tepung terigu':
        'Bahan berbasis gandum dan sumber karbohidrat. Mengandung gluten; perlu diperhatikan oleh orang dengan alergi gandum atau penyakit celiac.',
    'susu bubuk':
        'Bahan berbasis susu yang dapat menyumbang protein dan lemak. Mengandung alergen susu.',
    'minyak sawit':
        'Sumber lemak nabati. Jumlah lemak total dan lemak jenuh perlu diperiksa pada tabel gizi.',
    'air': 'Pelarut dan bagian cair produk.',
    'lesitin kedelai':
        'Pengemulsi yang membantu mencampur bahan. Berasal dari kedelai; perhatikan label alergen.',
  };
  return info[key] ??
      'Bahan ini belum ada dalam kamus lokal. Tidak ada kesimpulan keamanan atau kandungan gizi yang dapat ditetapkan hanya dari namanya. Periksa keterangan produsen dan label alergen.';
}
