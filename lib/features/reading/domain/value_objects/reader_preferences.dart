/// Reader preferences (docs/41 §4.3, §35) — the reader-adjustable typography of
/// the reading surface: font size (S/M/L), line-height, and reading column width.
/// Theme (light/dark/system) is NOT here — it is device-wide and owned by
/// `themeModeController` (docs/41 §22); the reader-settings sheet surfaces both.
///
/// A pure value object with correct value equality so provider `select`s rebuild
/// only on a real change. Persisted per-device via [PreferencesStore] and applied
/// live to the reading renderer (docs/40 §26.1 — device prefs survive logout).
library;

import 'package:flutter/foundation.dart';

import '../../../../shared/domain/enums.dart';

/// The reader font size. The concrete px is resolved per-script by the reading
/// typography helper (Latin/Hindi vs Nastaliq differ) — this only carries the
/// user's chosen step (docs/41 §4.3: Latin 18/20/22, Nastaliq 20/22/24).
enum ReadingFontSize {
  small('small'),
  medium('medium'),
  large('large');

  const ReadingFontSize(this.wire);

  final String wire;

  static ReadingFontSize fromWire(
    String? value, {
    ReadingFontSize fallback = ReadingFontSize.medium,
  }) => values.firstWhere(
    (ReadingFontSize e) => e.wire == value,
    orElse: () => fallback,
  );

  /// The base body px for a Latin/Devanagari reading surface.
  double get latinPx => switch (this) {
    ReadingFontSize.small => 18,
    ReadingFontSize.medium => 20,
    ReadingFontSize.large => 22,
  };

  /// The base body px for a Nastaliq (Urdu) reading surface — one step larger
  /// (docs/41 §4.3: 20/22/24; Nastaliq is never set below 20).
  double get nastaliqPx => switch (this) {
    ReadingFontSize.small => 20,
    ReadingFontSize.medium => 22,
    ReadingFontSize.large => 24,
  };
}

/// The reader line-height, expressed as a multiplier applied to the per-script
/// base leading. The base leadings (docs/41 §4.3) are 1.7 Latin / 1.8 Devanagari
/// / 2.1 Nastaliq; the multiplier scales them, and Nastaliq is clamped to never
/// fall below 2.0 (a non-negotiable script accommodation, docs/41 §4.4).
enum ReadingLineHeight {
  compact('compact', 0.92),
  normal('normal', 1.0),
  relaxed('relaxed', 1.12);

  const ReadingLineHeight(this.wire, this.multiplier);

  final String wire;
  final double multiplier;

  static ReadingLineHeight fromWire(
    String? value, {
    ReadingLineHeight fallback = ReadingLineHeight.normal,
  }) => values.firstWhere(
    (ReadingLineHeight e) => e.wire == value,
    orElse: () => fallback,
  );
}

/// The reading column width. On a phone the column is naturally the full width
/// minus gutters; this cap only bites on tablet/landscape so the measure never
/// exceeds ~65–72ch (docs/41 §4.3, §25–§26). `full` removes the cap.
enum ReadingWidth {
  narrow('narrow', 560),
  medium('medium', 680),
  wide('wide', 820);

  const ReadingWidth(this.wire, this.maxContentWidth);

  final String wire;

  /// The maximum logical-pixel width of the reading column.
  final double maxContentWidth;

  static ReadingWidth fromWire(
    String? value, {
    ReadingWidth fallback = ReadingWidth.medium,
  }) => values.firstWhere(
    (ReadingWidth e) => e.wire == value,
    orElse: () => fallback,
  );
}

/// The reader-adjustable typography, as one immutable value.
@immutable
class ReaderPreferences {
  const ReaderPreferences({
    this.fontSize = ReadingFontSize.medium,
    this.lineHeight = ReadingLineHeight.normal,
    this.width = ReadingWidth.medium,
  });

  final ReadingFontSize fontSize;
  final ReadingLineHeight lineHeight;
  final ReadingWidth width;

  /// The default reading preferences (M size, normal leading, medium column).
  static const ReaderPreferences initial = ReaderPreferences();

  ReaderPreferences copyWith({
    ReadingFontSize? fontSize,
    ReadingLineHeight? lineHeight,
    ReadingWidth? width,
  }) => ReaderPreferences(
    fontSize: fontSize ?? this.fontSize,
    lineHeight: lineHeight ?? this.lineHeight,
    width: width ?? this.width,
  );

  /// Resolve the base body font size (px) for a piece's [direction].
  double bodyPx(TextDirectionKind direction) =>
      direction == TextDirectionKind.rtl
      ? fontSize.nastaliqPx
      : fontSize.latinPx;

  /// Resolve the effective line-height for a piece's [direction], applying the
  /// user multiplier to the per-script base and clamping Nastaliq to ≥ 2.0.
  double lineHeightFor(TextDirectionKind direction) {
    final double base = switch (direction) {
      TextDirectionKind.rtl => 2.1,
      TextDirectionKind.ltr => 1.7,
    };
    final double scaled = base * lineHeight.multiplier;
    return direction == TextDirectionKind.rtl
        ? (scaled < 2.0 ? 2.0 : scaled)
        : scaled;
  }

  @override
  bool operator ==(Object other) =>
      other is ReaderPreferences &&
      other.fontSize == fontSize &&
      other.lineHeight == lineHeight &&
      other.width == width;

  @override
  int get hashCode => Object.hash(fontSize, lineHeight, width);
}
