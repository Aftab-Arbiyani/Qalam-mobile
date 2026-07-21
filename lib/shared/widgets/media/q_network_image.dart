/// Network image (docs/41 §11.11, docs/40 §35). Disk+memory cached, skeleton
/// placeholder, graceful error fallback, explicit dimensions to avoid layout
/// shift. In dark mode covers are dimmed ~8% (docs/41 §21) — never inverted.
///
/// Callers pass a resolved URL (built from a storage key via `MediaUrlBuilder`);
/// this widget does not resolve keys itself.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/q_tokens.dart';

class QNetworkImage extends StatelessWidget {
  const QNetworkImage({
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.circle = false,
    this.borderRadius,
    super.key,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool circle;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);

    Widget placeholder() =>
        Container(width: width, height: height, color: tokens.colors.bgRaised);

    Widget image;
    if (url == null || url!.isEmpty) {
      image = placeholder();
    } else {
      // Decode at DISPLAY size, not source size (docs/40 §35.2, P7.3): the single
      // biggest image-memory win. Cap the decoded bitmap to the layout box scaled
      // by the device pixel ratio so a 2000px cover doesn't sit full-res in the
      // image cache. Null when the box is unbounded (fall back to source decode).
      final double dpr = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 1.0;
      final int? memWidth = width != null && width!.isFinite ? (width! * dpr).round() : null;
      final int? memHeight = height != null && height!.isFinite ? (height! * dpr).round() : null;
      image = CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: memWidth,
        memCacheHeight: memHeight,
        placeholder: (BuildContext context, _) => placeholder(),
        errorWidget: (BuildContext context, _, _) => placeholder(),
      );
      if (tokens.isDark) {
        image = ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Color(0x14000000),
            BlendMode.darken,
          ),
          child: image,
        );
      }
    }

    if (circle) return ClipOval(child: image);
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: image,
    );
  }
}
