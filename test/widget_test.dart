import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komposisiku/main.dart';

void main() {
  testWidgets('komposisi manual membuka penjelasan bahan', (tester) async {
    await tester.pumpWidget(const KomposisiKuApp());
    await tester.enterText(find.byType(TextField), 'Komposisi: gula, garam');
    await tester.tap(find.text('Tampilkan komposisi'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('gula'));
    await tester.tap(find.text('gula'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Memberi rasa manis'), findsOneWidget);
  });
  testWidgets('Nutri-Level meminta konfirmasi sebelum menilai', (tester) async {
    await tester.pumpWidget(const KomposisiKuApp());
    await tester.tap(find.text('Nutri-Level'));
    await tester.pumpAndSettle();
    expect(find.text('Jenis produk'), findsOneWidget);
    expect(find.textContaining('Estimasi level'), findsNothing);
  });
  testWidgets('nilai gizi manual ditampilkan sebagai tabel per sajian',
      (tester) async {
    await tester.pumpWidget(const KomposisiKuApp());
    await tester.tap(find.text('Nilai Gizi'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField),
        'Takaran saji 250 ml\nGula total 19 g\nNatrium 100 mg\nLemak jenuh 1 g');
    await tester.ensureVisible(find.text('Buat tabel nilai gizi'));
    await tester.tap(find.text('Buat tabel nilai gizi'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('INFORMASI NILAI GIZI'));
    expect(find.text('Takaran saji: 250 ml'), findsOneWidget);
    expect(find.text('19 g'), findsOneWidget);
    expect(find.text('100 mg'), findsOneWidget);
  });
}
