/// GENERATED — do not edit by hand (umberleaf-brand/generate_outline.py).
///
/// The Umberleaf brand glyph, variant D "Outline": a single leaf — silhouette,
/// midrib and stem — as three centerline contours in a 1000x1000 icon box, meant
/// to be painted as a STROKE (round caps and joins) of [kUmberleafStrokeWidth],
/// scaled by `size / kUmberleafGlyphBox`. Pure geometry: no font, no flutter_svg,
/// identical on every platform at any size.
library;

import 'dart:ui';

/// Design-space size the path is authored in; scale by `size / kUmberleafGlyphBox`.
const double kUmberleafGlyphBox = 1000;

/// Stroke width in the 1000-box. Painter: `strokeWidth = kUmberleafStrokeWidth * size / kUmberleafGlyphBox`,
/// `style = PaintingStyle.stroke`, `strokeCap = StrokeCap.round`, `strokeJoin = StrokeJoin.round`.
const double kUmberleafStrokeWidth = 32.16;

/// Build the leaf centerlines (one closed silhouette + two open lines). Stroke it; do not fill.
Path buildUmberleafGlyphPath() {
  return Path()
    ..moveTo(374.37, 736.04)
    ..cubicTo(701.86, 805.11, 770.10, 400.13, 664.70, 190.00)
    ..cubicTo(445.38, 220.47, 161.62, 503.86, 374.37, 736.04)
    ..close()
    ..moveTo(383.08, 719.66)
    ..lineTo(589.22, 331.97)
    ..moveTo(374.37, 736.04)
    ..cubicTo(352.16, 777.82, 306.49, 795.21, 289.52, 810.00);
}
