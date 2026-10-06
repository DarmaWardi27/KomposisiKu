import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'label_parser.dart';
import 'nutri_page.dart';
import 'ocr_rows.dart';

void main() => runApp(const KomposisiKuApp());

class KomposisiKuApp extends StatelessWidget {
  const KomposisiKuApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'KomposisiKu',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff18765b)),
          scaffoldBackgroundColor: const Color(0xfff6f8f5),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        home: const ScanPage(),
      );
}

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});
  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  int _tab = 0;
  bool _busy = false;
  final _composition = TextEditingController();
  final _nutrition = TextEditingController();
  List<String> _ingredients = [];
  NutritionLabel? _label;
  String? _error;

  Future<void> _scan(ImageSource source) async {
    final target = _tab;
    if (target > 1 || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    TextRecognizer? recognizer;
    try {
      final photo = await ImagePicker().pickImage(source: source);
      if (photo == null) return;
      recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final result = await recognizer.processImage(
        InputImage.fromFilePath(photo.path),
      );
      if (!mounted) return;
      if (result.text.trim().isEmpty) {
        setState(
          () => _error =
              'Tulisan belum terbaca. Foto ulang dengan cahaya cukup dan label yang tajam.',
        );
      } else {
        setState(() {
          (target == 0 ? _composition : _nutrition).text = target == 0
              ? result.text
              : nutritionRows([
                  for (final block in result.blocks)
                    for (final line in block.lines)
                      OcrSegment(line.text, line.boundingBox.left,
                          line.boundingBox.top, line.boundingBox.height),
                ]);
          if (target == 0) {
            _ingredients = [];
          } else {
            _label = null;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Foto tidak dapat dibaca. Periksa izin kamera/galeri, atau masukkan teks label secara manual.',
        );
      }
    } finally {
      await recognizer?.close();
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _composition.dispose();
    _nutrition.dispose();
    super.dispose();
  }

  void _process() {
    setState(() {
      _error = null;
      if (_tab == 0) {
        _ingredients = parseIngredients(_composition.text);
        if (_ingredients.isEmpty) {
          _error = 'Masukkan tulisan komposisi terlebih dahulu.';
        }
      } else {
        _label = NutritionLabel.parse(_nutrition.text);
        if (_label!.nutrients.isEmpty) {
          _error =
              'Nilai gizi belum terbaca. Gunakan satu baris per zat gizi, misalnya: Gula total 12 g.';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('KomposisiKu'),
          actions: [
            IconButton(
              tooltip: 'Tentang aplikasi',
              icon: const Icon(Icons.info_outline),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Kenali isi kemasan'),
                  content: const Text(
                    'Foto diproses oleh OCR pada perangkat. Selalu cocokkan hasil pembacaan dengan label asli. Penjelasan bahan bersifat edukasi umum, bukan penilaian keamanan produk.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Mengerti'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: _busy
              ? null
              : (value) => setState(() {
                    _tab = value;
                    _error = null;
                  }),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.grain_outlined),
              label: 'Komposisi',
            ),
            NavigationDestination(
              icon: Icon(Icons.table_chart_outlined),
              label: 'Nilai Gizi',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              label: 'Nutri-Level',
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    _tab == 0
                        ? 'Kenali setiap bahan.'
                        : _tab == 1
                            ? 'Baca gizi dengan jelas.'
                            : 'Pahami kategori produk.',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _tab == 0
                        ? 'Foto bagian komposisi, periksa teks, lalu ketuk bahan untuk mengetahui informasinya.'
                        : _tab == 1
                            ? 'Foto tabel pada kemasan dan periksa angkanya sebelum membuat tabel gizi.'
                            : 'Kategori memerlukan data lengkap dan aturan resmi yang sesuai dengan jenis produk.',
                  ),
                  const SizedBox(height: 24),
                  if (_tab < 2) ...[
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed:
                              _busy ? null : () => _scan(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Foto label'),
                        ),
                        OutlinedButton.icon(
                          onPressed:
                              _busy ? null : () => _scan(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Dari galeri'),
                        ),
                      ],
                    ),
                    if (_busy)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: LinearProgressIndicator(),
                      ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _tab == 0 ? _composition : _nutrition,
                      minLines: 5,
                      maxLines: 12,
                      onChanged: (_) => setState(() {
                        if (_tab == 0) {
                          _ingredients = [];
                        } else {
                          _label = null;
                        }
                      }),
                      decoration: InputDecoration(
                        labelText: 'Teks label · bisa dikoreksi',
                        hintText: _tab == 0
                            ? 'Komposisi: tepung terigu, gula, garam'
                            : 'Takaran saji 30 g\nEnergi total 140 kkal\nGula total 12 g\nNatrium 90 mg',
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _busy ? null : _process,
                      child: Text(
                        _tab == 0
                            ? 'Tampilkan komposisi'
                            : 'Buat tabel nilai gizi',
                      ),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                  if (_tab == 0)
                    ..._ingredients.map(
                      (ingredient) => Card(
                        child: ListTile(
                          title: Text(ingredient),
                          subtitle: const Text('Ketuk untuk mengenal bahan'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => showModalBottomSheet<void>(
                            context: context,
                            showDragHandle: true,
                            builder: (_) => SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ingredient,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(ingredientInfo(ingredient)),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_tab == 1 &&
                      _label != null &&
                      _label!.nutrients.isNotEmpty)
                    _nutritionTable(),
                  if (_tab == 2) NutriPage(label: _label),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _nutritionTable() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'INFORMASI NILAI GIZI',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
            ),
            const Divider(color: Colors.black, thickness: 4),
            Text(
              'Takaran saji: ${_label!.serving ?? "Belum terbaca — periksa label"}',
            ),
            const Text(
              'Jumlah per sajian',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(color: Colors.black, thickness: 2),
            const Row(
              children: [
                Expanded(child: Text('Zat gizi')),
                Text('Jumlah'),
                SizedBox(width: 20),
                Text('% AKG'),
              ],
            ),
            ..._label!.nutrients.map(
              (n) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    Expanded(child: Text(n.name)),
                    Text(
                      '${n.amount.toString().replaceAll(RegExp(r"\.0$"), "")} ${n.unit}',
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 48,
                      child: Text(
                        n.dailyPercent == null ? '—' : '${n.dailyPercent}%',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.black),
            const Text(
              'Tabel ini adalah transkripsi label, bukan perhitungan AKG baru. Tanda — berarti data belum terbaca. Cocokkan setiap angka dengan kemasan.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
}
