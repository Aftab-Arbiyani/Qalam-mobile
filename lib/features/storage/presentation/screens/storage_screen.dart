/// Storage & cache management screen (docs/40 §25, §37). Shows total local usage,
/// a per-box breakdown (what is disposable cache vs. the user's own data), cache
/// statistics, and the two maintenance actions — clean up expired entries and clear
/// the cache. Manual refresh re-measures. Durable user data (reading history,
/// offline drafts, the sync queue) is measured but never cleared here.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/cache_manager.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/radius_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/feedback/q_snackbar.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../providers/storage_providers.dart';

/// Human byte size: 0 → "0 B", 2048 → "2.0 KB", 5_242_880 → "5.0 MB".
String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final double kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
  final double mb = kb / 1024;
  if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
  return '${(mb / 1024).toStringAsFixed(1)} GB';
}

class StorageScreen extends ConsumerWidget {
  const StorageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CacheStats stats = ref.watch(cacheStatsControllerProvider);
    final CacheStatsController controller = ref.read(
      cacheStatsControllerProvider.notifier,
    );
    final ThemeData theme = Theme.of(context);
    final QTokens tokens = QTokens.of(context);

    return QScaffold(
      appBar: const QAppBar(title: 'Storage & cache'),
      body: RefreshIndicator(
        onRefresh: () async => controller.refresh(),
        child: ListView(
          padding: QSpacing.pagePadding,
          children: <Widget>[
            QCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Total on-device', style: theme.textTheme.bodySmall),
                  Gap.v1,
                  Text(
                    formatBytes(stats.totalBytes),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap.v1,
                  Text(
                    '${stats.cacheEntries} cached items · ${stats.expiredEntries} expired',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: tokens.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Gap.v5,
            Text('Breakdown', style: theme.textTheme.titleSmall),
            Gap.v2,
            for (final BoxUsage box in stats.boxes)
              _UsageRow(box: box, total: stats.totalBytes),
            Gap.v5,
            _MaintenanceActions(controller: controller, stats: stats),
            Gap.v5,
          ],
        ),
      ),
    );
  }
}

class _UsageRow extends StatelessWidget {
  const _UsageRow({required this.box, required this.total});

  final BoxUsage box;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final QTokens tokens = QTokens.of(context);
    final double fraction = total <= 0 ? 0 : box.approxBytes / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: QSpacing.s3),
      child: Semantics(
        container: true,
        label:
            '${box.label}, ${box.entries} items, ${formatBytes(box.approxBytes)}'
            '${box.clearable ? ', clearable cache' : ', your data'}',
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(box.label, style: theme.textTheme.bodyMedium),
                  ),
                  Text(
                    formatBytes(box.approxBytes),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: tokens.colors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: QRadii.controlRadius,
                child: LinearProgressIndicator(
                  value: fraction.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: tokens.colors.bgRaised,
                  color: box.clearable
                      ? tokens.colors.accent
                      : tokens.colors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${box.entries} items · ${box.clearable ? 'Disposable cache' : 'Your data'}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: tokens.colors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MaintenanceActions extends StatelessWidget {
  const _MaintenanceActions({required this.controller, required this.stats});

  final CacheStatsController controller;
  final CacheStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        OutlinedButton.icon(
          onPressed: () async {
            final int removed = await controller.cleanupExpired();
            if (context.mounted) {
              QSnackbar.show(
                context,
                message: removed == 0
                    ? 'Nothing to clean up.'
                    : 'Removed $removed expired item(s).',
              );
            }
          },
          icon: const Icon(Icons.cleaning_services_outlined, size: 18),
          label: const Text('Clean up expired'),
        ),
        Gap.v2,
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: QTokens.of(context).colors.danger,
          ),
          onPressed: () async {
            final bool confirmed = await _confirmClear(context);
            if (!confirmed) return;
            await controller.clearCache();
            if (context.mounted) {
              QSnackbar.show(context, message: 'Cache cleared.');
            }
          },
          icon: const Icon(Icons.delete_sweep_outlined, size: 18),
          label: const Text('Clear cached content'),
        ),
      ],
    );
  }

  Future<bool> _confirmClear(BuildContext context) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Clear cached content?'),
        content: const Text(
          'This frees space by removing cached pages and images. Your reading '
          'history, drafts and pending changes are kept.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }
}
