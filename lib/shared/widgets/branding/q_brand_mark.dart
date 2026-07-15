/// The Qalam brand mark (docs/41 §3) — the isolated Arabic letter qaf (ق) that is
/// also the app launcher icon. Painted from a baked vector [Path] (see
/// [buildQalamGlyphPath]) so it renders identically on every platform with no
/// bundled font and no `flutter_svg` dependency, crisp at any size.
///
/// Two forms:
/// - tiled (default) — the full icon: white ق on the warm terracotta rounded tile,
///   for splash / launcher-parity surfaces;
/// - untiled ([tile] = false) — just the ق in [glyphColor] (defaults to the theme
///   accent), for inline use on the paper canvas (e.g. an app-bar lockup).
library;

import 'package:flutter/material.dart';

import '../../theme/q_tokens.dart';
import 'qalam_glyph_path.dart';

/// The brand terracotta. A logo is theme-invariant, so the tile color is fixed
/// (it mirrors the light-theme accent, docs/41 §3.2) rather than following the
/// active theme.
const Color kQalamBrandTerracotta = Color(0xFF9E4B28);

class QBrandMark extends StatelessWidget {
  const QBrandMark({
    this.size = 40,
    this.tile = true,
    this.glyphColor,
    this.semanticLabel = 'Qalam',
    super.key,
  });

  /// Edge length of the (square) mark in logical pixels.
  final double size;

  /// Whether to paint the terracotta rounded tile behind the glyph.
  final bool tile;

  /// Glyph fill. Defaults to white on a tile, or the theme accent when untiled.
  final Color? glyphColor;

  /// Screen-reader label; pass `null` where the mark sits beside the "Qalam"
  /// wordmark (splash / app bar) so the name isn't announced twice.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final Color resolved =
        glyphColor ?? (tile ? Colors.white : QTokens.of(context).colors.accent);
    final Widget mark = SizedBox.square(
      dimension: size,
      child: CustomPaint(
        size: Size.square(size),
        painter: _QBrandMarkPainter(tile: tile, glyphColor: resolved),
      ),
    );
    if (semanticLabel == null) return ExcludeSemantics(child: mark);
    return Semantics(label: semanticLabel, image: true, child: mark);
  }
}

class _QBrandMarkPainter extends CustomPainter {
  _QBrandMarkPainter({required this.tile, required this.glyphColor});

  final bool tile;
  final Color glyphColor;

  /// The glyph outline is authored once in a 1000×1000 box; reused across paints.
  static final Path _glyph = buildQalamGlyphPath();

  @override
  void paint(Canvas canvas, Size size) {
    if (tile) {
      final double radius = size.width * 112 / 512; // match the launcher tile
      canvas.drawRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
        Paint()
          ..color = kQalamBrandTerracotta
          ..isAntiAlias = true,
      );
    }
    canvas.save();
    canvas.scale(size.width / kQalamGlyphBox);
    canvas.drawPath(
      _glyph,
      Paint()
        ..color = glyphColor
        ..isAntiAlias = true,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_QBrandMarkPainter old) =>
      old.tile != tile || old.glyphColor != glyphColor;
}
