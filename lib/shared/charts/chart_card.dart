/// A titled card that renders a chart with its three required states — loading,
/// empty and error (docs/41 §charts, §32/§33) — from an [AsyncValue]. Every
/// analytics chart goes through this so the states look identical everywhere:
/// a skeleton while loading, a calm empty note when there is no data (the normal
/// case for on-demand growth snapshots), and honest error copy with a retry on
/// failure. The whole card is a semantics container so screen readers announce the
/// title before the chart's own summary.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/error_messages.dart';
import '../../core/error/failure.dart';
import '../theme/q_tokens.dart';
import '../theme/tokens/spacing_tokens.dart';
import '../widgets/buttons/q_button.dart';
import '../widgets/cards/q_card.dart';
import '../widgets/loading/q_skeleton.dart';

class AnalyticsChartCard<T> extends StatelessWidget {
  const AnalyticsChartCard({
    required this.title,
    required this.value,
    required this.isEmpty,
    required this.chartBuilder,
    this.subtitle,
    this.emptyMessage = 'No data for this range yet.',
    this.chartHeight = 180,
    this.onRetry,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final AsyncValue<T> value;
  final bool Function(T data) isEmpty;
  final Widget Function(T data) chartBuilder;
  final String emptyMessage;
  final double chartHeight;
  final VoidCallback? onRetry;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final QTokens tokens = QTokens.of(context);

    return QCard(
      padding: QCardPadding.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: theme.textTheme.titleSmall),
                    if (subtitle != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: tokens.colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          Gap.v3,
          SizedBox(
            height: chartHeight,
            width: double.infinity,
            child: _body(context),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    return value.when(
      skipLoadingOnRefresh: false,
      loading: () => QSkeleton(height: chartHeight, width: double.infinity),
      error: (Object error, StackTrace _) => _ChartError(
        failure: error is Failure
            ? error
            : const Failure.unexpected(code: 'UNKNOWN'),
        onRetry: onRetry,
      ),
      data: (T data) => isEmpty(data)
          ? _ChartEmpty(message: emptyMessage)
          : Center(child: chartBuilder(data)),
    );
  }
}

class _ChartEmpty extends StatelessWidget {
  const _ChartEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.insights_outlined,
          color: tokens.colors.textMuted,
          size: 28,
        ),
        Gap.v2,
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: tokens.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ChartError extends StatelessWidget {
  const _ChartError({required this.failure, this.onRetry});

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final QTokens tokens = QTokens.of(context);
    final ErrorCopy copy = ErrorMessages.of(failure);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.cloud_off_outlined, color: tokens.colors.textMuted, size: 28),
        Gap.v2,
        Text(
          copy.title,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: tokens.colors.textSecondary,
          ),
        ),
        if (onRetry != null) ...<Widget>[
          Gap.v2,
          QButton(
            label: 'Try again',
            size: QButtonSize.sm,
            onPressed: onRetry,
          ),
        ],
      ],
    );
  }
}
