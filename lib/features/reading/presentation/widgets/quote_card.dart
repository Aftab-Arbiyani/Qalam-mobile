/// Featured-quote card (docs/41 §11.2 QuoteCard, §35). Accent-subtle tint, an
/// oversized opening-quote glyph, the quote in the reading size (italic for
/// Latin/Hindi, regular for Urdu). Rendered from the piece's top-level
/// `featuredQuote` string — it is NOT part of the body content.
library;

import 'package:flutter/material.dart';

import '../../../../shared/domain/enums.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/radius_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';

class QuoteCard extends StatelessWidget {
  const QuoteCard({required this.quote, required this.direction, super.key});

  final String quote;
  final TextDirectionKind direction;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final bool isRtl = direction == TextDirectionKind.rtl;

    return Container(
      width: double.infinity,
      padding: QSpacing.cardPadding,
      decoration: BoxDecoration(
        color: tokens.colors.accentSubtle,
        borderRadius: QRadii.cardRadius,
      ),
      child: Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '“',
              style: TextStyle(
                fontSize: 44,
                height: 1,
                fontWeight: FontWeight.w600,
                color: tokens.colors.accent,
              ),
            ),
            const SizedBox(height: QSpacing.s1),
            Text(
              quote,
              style: TextStyle(
                fontSize: 20,
                height: 1.5,
                fontStyle: isRtl ? FontStyle.normal : FontStyle.italic,
                color: tokens.colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
