/// A compact token-usage / provenance line for a completed generation (AF2) — tokens
/// used, estimated cost, and the provider/model that answered. Muted, non-critical.
/// The full daily/monthly/lifetime + quota breakdown lives on the usage screen.
library;

import 'package:flutter/material.dart';

import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../domain/entities/ai_stream_event.dart';

class TokenUsageLine extends StatelessWidget {
  const TokenUsageLine({
    this.usage,
    this.provider,
    this.model,
    this.estimatedCostUsd,
    super.key,
  });

  final AiTokenUsage? usage;
  final String? provider;
  final String? model;
  final double? estimatedCostUsd;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final TextStyle style = Theme.of(context)
        .textTheme
        .bodySmall!
        .copyWith(color: tokens.colors.textMuted);

    final List<String> parts = <String>[
      if (usage != null) '${_formatInt(usage!.totalTokens)} tokens',
      if (estimatedCostUsd != null && estimatedCostUsd! > 0)
        '\$${estimatedCostUsd!.toStringAsFixed(4)}',
      if ((provider ?? '').isNotEmpty)
        (model ?? '').isNotEmpty ? '$provider · $model' : provider!,
    ];
    if (parts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: QSpacing.s1),
      child: Row(
        children: <Widget>[
          Icon(Icons.bolt_outlined, size: 14, color: tokens.colors.textMuted),
          const SizedBox(width: QSpacing.s1),
          Expanded(
            child: Text(parts.join('  ·  '), style: style, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  static String _formatInt(int value) {
    final String s = value.toString();
    final StringBuffer out = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
      out.write(s[i]);
    }
    return out.toString();
  }
}
