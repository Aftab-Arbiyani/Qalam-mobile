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
      image = CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: fit,
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
