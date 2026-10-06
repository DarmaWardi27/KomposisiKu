import 'package:flutter/material.dart';
import 'label_parser.dart';
import 'nutri_level.dart';

class NutriPage extends StatefulWidget {
  const NutriPage({super.key, required this.label});
  final NutritionLabel? label;
  @override
  State<NutriPage> createState() => _NutriPageState();
}

class _NutriPageState extends State<NutriPage> {
  final _serving = TextEditingController();
  final _sugar = TextEditingController();
  final _sodium = TextEditingController();
  final _fat = TextEditingController();
  final _lactose = TextEditingController();
  String? _scope;
  Sweetener? _sweetener;
  bool _confirmed = false;
  bool _naturallyFree = false;
  String? _error;
  NutriAssessment? _result;

  @override
  void initState() {
    super.initState();
    final label = widget.label;
    if (label == null) return;
    final serving = label.serving;
    if (serving != null && serving.toLowerCase().contains('ml')) {
      _serving.text = serving.replaceAll(RegExp(r'[^\d,.]'), '');
    }
    for (final n in label.nutrients) {
      if ((n.name == 'Gula total' || n.name == 'Gula') && n.unit == 'g') {
        _sugar.text = '${n.amount}';
      }
      if (n.name == 'Natrium' && n.unit == 'mg') _sodium.text = '${n.amount}';
      if (n.name == 'Lemak jenuh' && n.unit == 'g') _fat.text = '${n.amount}';
    }
  }

  @override
  void dispose() {
    for (final c in [_serving, _sugar, _sodium, _fat, _lactose]) {
      c.dispose();
    }
    super.dispose();
  }

  double _number(TextEditingController controller) =>
      double.parse(controller.text.trim().replaceAll(',', '.'));
  void _calculate() {
    setState(() {
      _error = null;
      _result = null;
    });
    if (_scope != 'drink') {
      setState(
        () => _error =
            'Aturan ini hanya untuk minuman olahan siap saji. Pilih jenis produk yang sesuai.',
      );
      return;
    }
    if (_sweetener == null || !_confirmed) {
      setState(
        () =>
            _error = 'Pilih jenis BTP pemanis dan konfirmasi angka dari label.',
      );
      return;
    }
    try {
      final result = assessDrink(
        servingMl: _number(_serving),
        sugarGrams: _number(_sugar),
        sodiumMg: _number(_sodium),
        saturatedFatGrams: _number(_fat),
        lactoseGrams: _lactose.text.trim().isEmpty ? 0 : _number(_lactose),
        sweetener: _sweetener!,
      );
      if (_naturallyFree) {
        if (result.sugar != 0 ||
            result.sodium != 0 ||
            result.saturatedFat != 0 ||
            _sweetener != Sweetener.none) {
          setState(
            () => _error =
                'Pernyataan bebas alami tidak cocok dengan data. Periksa kembali label dan komposisi.',
          );
        } else {
          setState(
            () => _error =
                'Menurut lampiran A angka 10, minuman yang secara alami tidak mengandung gula, garam, dan lemak tidak mencantumkan Nutri-Level.',
          );
        }
        return;
      }
      setState(() => _result = result);
    } on FormatException {
      setState(
        () => _error =
            'Lengkapi angka per sajian. Data kosong tidak dianggap nol.',
      );
    } on ArgumentError catch (e) {
      setState(() => _error = '${e.message}');
    }
  }

  Widget _field(String label, TextEditingController controller) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {
            _confirmed = false;
            _result = null;
          }),
          decoration: InputDecoration(labelText: label),
        ),
      );

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'KMK HK.01.07/MENKES/301/2026',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lampiran mengatur minuman olahan siap saji per 100 ml. Hasil aplikasi adalah estimasi dari label yang Anda konfirmasi, bukan pengesahan label resmi atau hasil uji laboratorium.',
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: _scope,
            decoration: const InputDecoration(labelText: 'Jenis produk'),
            items: const [
              DropdownMenuItem(
                value: 'drink',
                child: Text('Minuman olahan siap saji'),
              ),
              DropdownMenuItem(
                value: 'other',
                child: Text('Produk lain / belum diketahui'),
              ),
            ],
            onChanged: (value) => setState(() {
              _scope = value;
              _result = null;
            }),
          ),
          const SizedBox(height: 16),
          _field('Takaran saji (ml)', _serving),
          _field('Gula total per sajian (g)', _sugar),
          _field('Laktosa per sajian (g), jika tercantum', _lactose),
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Jika laktosa tidak tercantum, gunakan gula total tanpa pengurangan, sesuai contoh dalam lampiran.',
            ),
          ),
          _field('Natrium per sajian (mg)', _sodium),
          _field('Lemak jenuh per sajian (g)', _fat),
          DropdownButtonFormField<Sweetener>(
            initialValue: _sweetener,
            decoration: const InputDecoration(
              labelText: 'Bahan tambahan pangan (BTP) pemanis',
            ),
            items: const [
              DropdownMenuItem(
                value: Sweetener.none,
                child: Text('Tanpa BTP pemanis'),
              ),
              DropdownMenuItem(
                value: Sweetener.natural,
                child: Text('BTP pemanis alami'),
              ),
              DropdownMenuItem(
                value: Sweetener.artificial,
                child: Text('BTP pemanis buatan / campuran'),
              ),
            ],
            onChanged: (value) => setState(() {
              _sweetener = value;
              _result = null;
            }),
          ),
          const SizedBox(height: 12),
          const Text(
            'Periksa komposisi dan informasi produsen, termasuk pemanis ikutan (carry over). Jika belum diketahui, jangan memilih secara perkiraan.',
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Secara alami tanpa gula, garam, dan lemak'),
            value: _naturallyFree,
            onChanged: (v) => setState(() {
              _naturallyFree = v!;
              _result = null;
            }),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Saya sudah mencocokkan angka dan jenis produk dengan label asli',
            ),
            value: _confirmed,
            onChanged: (v) => setState(() {
              _confirmed = v!;
              _result = null;
            }),
          ),
          FilledButton(
            onPressed: _calculate,
            child: const Text('Hitung estimasi Nutri-Level'),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (_result != null) ...[
            const SizedBox(height: 20),
            Card(
              color: [
                const Color(0xffcce5d2),
                const Color(0xffdff0bf),
                const Color(0xffffe6a3),
                const Color(0xffffc9c5),
              ][_result!.grade],
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimasi level ${_result!.letter}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Per 100 ml\nGula tanpa laktosa: ${_result!.sugar.toStringAsFixed(1)} g · ${"ABCD"[_result!.componentGrades[0]]}\nNatrium: ${_result!.sodium.toStringAsFixed(2)} mg · ${"ABCD"[_result!.componentGrades[1]]}\nLemak jenuh: ${_result!.saturatedFat.toStringAsFixed(2)} g · ${"ABCD"[_result!.componentGrades[2]]}',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Estimasi ini mengambil kategori tertinggi dari ketiga indikator, lalu menerapkan pembatasan BTP pemanis. Gula dibulatkan satu desimal sebelum dinilai. Hasil ini bukan penetapan label resmi.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
}
