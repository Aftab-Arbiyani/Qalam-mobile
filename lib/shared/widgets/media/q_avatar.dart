/// Avatar (docs/41 §11.11). Circular; shows the cached network image when a URL
/// is present, else initials on a raised surface.
library;

import 'package:flutter/material.dart';

import '../../theme/q_tokens.dart';
import 'q_network_image.dart';

class QAvatar extends StatelessWidget {
  const QAvatar({required this.name, this.imageUrl, this.size = 32, super.key});

  final String name;
  final String? imageUrl;
  final double size;

  String get _initials {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return QNetworkImage(
        url: imageUrl,
        width: size,
        height: size,
        circle: true,
      );
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tokens.colors.bgRaised,
        shape: BoxShape.circle,
      ),
      child: Text(
        _initials,
        style: TextStyle(
          color: tokens.colors.textSecondary,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
