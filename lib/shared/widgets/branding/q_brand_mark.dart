/// The Umberleaf brand mark (docs/41 §3) — variant D "Outline": a single leaf
/// drawn as one continuous white stroke, which is also the app launcher icon.
/// Painted from a baked vector [Path] (see [buildUmberleafGlyphPath]) so it
/// renders identically on every platform with no bundled font and no
/// `flutter_svg` dependency, crisp at any size.
///
/// Two forms:
/// - tiled (default) — the full icon: white leaf on the warm terracotta rounded
///   tile, for splash / launcher-parity surfaces;
/// - untiled ([tile] = false) — just the leaf in [glyphColor] (defaults to the
///   theme accent), for inline use on the paper canvas (e.g. an app-bar lockup).
///
/// **The leaf is a STROKE, not a fill — that is load-bearing.** The path is three
/// centerline contours (a closed silhouette, the midrib, the stem). Painting it
/// with [PaintingStyle.fill] would flood the silhouette into a solid blob and
/// implicitly close and fill the two open lines as well. The previous mark (the
/// Arabic letter qaf) was a filled outline, so this is the one real behavioural
/// change in the swap.
library;

import 'package:flutter/material.dart';

import '../../theme/q_tokens.dart';
import 'umberleaf_glyph_path.dart';

/// The brand terracotta. A logo is theme-invariant, so the tile color is fixed
/// (it mirrors the light-theme accent, docs/41 §3.2) rather than following the
/// active theme. Value unchanged by the rebrand: the colour is the part of the
/// identity that survived the rename.
const Color kUmberleafBrandTerracotta = Color(0xFF9E4B28);

class QBrandMark extends StatelessWidget {
  const QBrandMark({
    this.size = 40,
    this.tile = true,
    this.glyphColor,
    this.semanticLabel = 'Umberleaf',
    super.key,
  });

  /// Edge length of the (square) mark in logical pixels.
  final double size;

  /// Whether to paint the terracotta rounded tile behind the glyph.
  final bool tile;

  /// Glyph stroke colour. Defaults to white on a tile, or the theme accent when
  /// untiled.
  final Color? glyphColor;

  /// Screen-reader label; pass `null` where the mark sits beside the "Umberleaf"
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

  /// The glyph centerlines are authored once in a 1000×1000 box; reused across
  /// paints.
  static final Path _glyph = buildUmberleafGlyphPath();

  @override
  void paint(Canvas canvas, Size size) {
    if (tile) {
      // 112/512 == 224/1024, the master tile's own corner radius, so the painted
      // mark and the generated launcher PNG round identically.
      final double radius = size.width * 112 / 512;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
        Paint()
          ..color = kUmberleafBrandTerracotta
          ..isAntiAlias = true,
      );
    }
    canvas.save();
    canvas.scale(size.width / kUmberleafGlyphBox);
    canvas.drawPath(
      _glyph,
      Paint()
        ..color = glyphColor
        ..style = PaintingStyle.stroke
        // Stroke width is given in design-space units. `canvas.scale` above
        // scales the stroke along with the geometry, so the rendered width is
        // `kUmberleafStrokeWidth * size / kUmberleafGlyphBox` — exactly the
        // formula the generator documents, obtained by transform rather than by
        // arithmetic. Do not pre-divide it here as well, or the stroke scales
        // quadratically and vanishes.
        ..strokeWidth = kUmberleafStrokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_QBrandMarkPainter old) =>
      old.tile != tile || old.glyphColor != glyphColor;
}
