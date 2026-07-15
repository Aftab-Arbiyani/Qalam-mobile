import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/reading/domain/value_objects/reader_preferences.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';

void main() {
  group('ReaderPreferences', () {
    test('body px is script-aware (Nastaliq one step larger)', () {
      const ReaderPreferences prefs =
          ReaderPreferences(); // medium is the default
      expect(prefs.bodyPx(TextDirectionKind.ltr), 20);
      expect(prefs.bodyPx(TextDirectionKind.rtl), 22);
    });

    test('font size steps', () {
      expect(
        const ReaderPreferences(
          fontSize: ReadingFontSize.small,
        ).bodyPx(TextDirectionKind.ltr),
        18,
      );
      expect(
        const ReaderPreferences(
          fontSize: ReadingFontSize.large,
        ).bodyPx(TextDirectionKind.ltr),
        22,
      );
    });

    test('line height scales the per-script base', () {
      const ReaderPreferences normal = ReaderPreferences();
      expect(normal.lineHeightFor(TextDirectionKind.ltr), closeTo(1.7, 1e-9));

      const ReaderPreferences relaxed = ReaderPreferences(
        lineHeight: ReadingLineHeight.relaxed,
      );
      expect(
        relaxed.lineHeightFor(TextDirectionKind.ltr),
        closeTo(1.7 * 1.12, 1e-9),
      );
    });

    test('Nastaliq line height never drops below 2.0 even when compact', () {
      const ReaderPreferences compact = ReaderPreferences(
        lineHeight: ReadingLineHeight.compact,
      );
      // 2.1 * 0.92 = 1.932 → clamped to 2.0.
      expect(compact.lineHeightFor(TextDirectionKind.rtl), 2.0);
    });

    test('copyWith and value equality', () {
      const ReaderPreferences a = ReaderPreferences();
      final ReaderPreferences b = a.copyWith(fontSize: ReadingFontSize.large);
      expect(b.fontSize, ReadingFontSize.large);
      expect(b, isNot(a));
      expect(a, const ReaderPreferences());
    });

    test('wire round-trips', () {
      expect(ReadingFontSize.fromWire('large'), ReadingFontSize.large);
      expect(ReadingFontSize.fromWire('nope'), ReadingFontSize.medium);
      expect(ReadingWidth.fromWire('wide').maxContentWidth, 820);
      expect(ReadingLineHeight.fromWire('relaxed'), ReadingLineHeight.relaxed);
    });
  });
}
