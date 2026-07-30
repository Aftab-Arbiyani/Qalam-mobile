/// Renders a [CoachReport] (AF2) — the Craft Coach's structured output as native
/// widgets: a writing-score dial, the coach summary, strengths / weaknesses,
/// improvement suggestions, actionable recommendations, and the per-aspect sections.
/// Read-only — coaching never touches the document.
library;

import 'package:flutter/material.dart';

import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/color_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../domain/value_objects/coach_report.dart';

class CoachReportView extends StatelessWidget {
  const CoachReportView({required this.report, super.key});

  final CoachReport report;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (report.score > 0 || report.summary.isNotEmpty) _summaryCard(context),
        _list(context, 'Strengths', report.strengths, Icons.check_circle_outline, _Tone.success),
        _list(context, 'Weaknesses', report.weaknesses, Icons.error_outline, _Tone.warning),
        _list(context, 'Improvement suggestions', report.suggestions, Icons.lightbulb_outline,
            _Tone.info),
        _list(context, 'Actionable recommendations', report.recommendations,
            Icons.playlist_add_check, _Tone.accent),
        _sections(context),
      ],
    );
  }

  Widget _summaryCard(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: QSpacing.s3),
      child: QCard(
        padding: QCardPadding.md,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _ScoreDial(score: report.score),
            const SizedBox(width: QSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Writing score', style: Theme.of(context).textTheme.labelMedium),
                  Gap.v1,
                  Text(
                    report.summary.isEmpty ? 'Overall craft assessment.' : report.summary,
                    style: TextStyle(color: tokens.colors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(BuildContext context, String title, List<String> items, IconData icon, _Tone tone) {
    if (items.isEmpty) return const SizedBox.shrink();
    final QTokens tokens = QTokens.of(context);
    final Color color = tone.color(tokens.colors);
    return Padding(
      padding: const EdgeInsets.only(bottom: QSpacing.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          Gap.v1,
          for (final String item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: QSpacing.s1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 2, right: QSpacing.s2),
                    child: Icon(icon, size: 16, color: color),
                  ),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _sections(BuildContext context) {
    if (report.sections.isEmpty) return const SizedBox.shrink();
    final QTokens tokens = QTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final CoachSection s in report.sections)
          Padding(
            padding: const EdgeInsets.only(bottom: QSpacing.s2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(s.title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                if (s.detail.isNotEmpty)
                  Text(s.detail, style: TextStyle(color: tokens.colors.textSecondary)),
              ],
            ),
          ),
      ],
    );
  }
}

enum _Tone {
  success,
  warning,
  info,
  accent;

  Color color(QColorSet c) => switch (this) {
        _Tone.success => c.successText,
        _Tone.warning => c.warningText,
        _Tone.info => c.infoText,
        _Tone.accent => c.accent,
      };
}

class _ScoreDial extends StatelessWidget {
  const _ScoreDial({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final Color color = score >= 70
        ? tokens.colors.success
        : score >= 40
            ? tokens.colors.warning
            : tokens.colors.danger;
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 5,
              backgroundColor: tokens.colors.bgRaised,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Text('$score',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
