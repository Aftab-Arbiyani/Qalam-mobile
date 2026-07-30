/// The one report control (docs/40 §13, E9) — reports a piece, comment, user, or
/// response. Generalized over [ReportEntityType] + entityId so a single sheet
/// serves every surface (docs/40 §44). Reason chips + optional details, then a
/// guarded submit through the shared [EngagementRepository]. Presented via the
/// shared [QBottomSheet]; shows a confirmation or a mapped error.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/error_messages.dart';
import '../../../core/error/failure.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../domain/enums.dart';
import '../../social/social_providers.dart';
import '../../theme/tokens/spacing_tokens.dart';
import '../buttons/q_button.dart';
import '../cards/q_chip.dart';
import '../feedback/q_bottom_sheet.dart';
import '../feedback/q_snackbar.dart';
import '../inputs/q_text_field.dart';

/// Present the report sheet for [entityType]/[entityId]. [title] is the localized
/// heading ("Report this piece", etc.).
Future<void> showReportSheet(
  BuildContext context, {
  required ReportEntityType entityType,
  required String entityId,
  required String title,
}) => QBottomSheet.show<void>(
  context,
  builder: (BuildContext context) => _ReportSheet(
    entityType: entityType,
    entityId: entityId,
    title: title,
  ),
);

/// The reasons offered, in order. `other` is last (free-text encouraged).
const List<ReportReason> _reasons = <ReportReason>[
  ReportReason.spam,
  ReportReason.harassment,
  ReportReason.hateSpeech,
  ReportReason.violence,
  ReportReason.sexualContent,
  ReportReason.selfHarm,
  ReportReason.misinformation,
  ReportReason.copyright,
  ReportReason.impersonation,
  ReportReason.other,
];

class _ReportSheet extends ConsumerStatefulWidget {
  const _ReportSheet({
    required this.entityType,
    required this.entityId,
    required this.title,
  });

  final ReportEntityType entityType;
  final String entityId;
  final String title;

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  ReportReason _reason = ReportReason.spam;
  final TextEditingController _detail = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _detail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          QSpacing.s4,
          QSpacing.s4,
          QSpacing.s4,
          QSpacing.s5,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(widget.title, style: theme.textTheme.titleLarge),
              Gap.v2,
              Text(
                l10n.reportReasonPrompt,
                style: theme.textTheme.bodyMedium,
              ),
              Gap.v3,
              Wrap(
                spacing: QSpacing.s2,
                runSpacing: QSpacing.s2,
                children: <Widget>[
                  for (final ReportReason r in _reasons)
                    QChip(
                      label: _reasonLabel(l10n, r),
                      tone: _reason == r ? QChipTone.accent : QChipTone.neutral,
                      onTap: () => setState(() => _reason = r),
                    ),
                ],
              ),
              Gap.v4,
              QTextField(
                label: '',
                controller: _detail,
                hint: l10n.reportDetailsHint,
                maxLength: 1000,
                maxLines: 3,
                minLines: 3,
                contentDirectionAuto: true,
              ),
              Gap.v4,
              SizedBox(
                width: double.infinity,
                child: QButton(
                  label: l10n.reportSubmit,
                  variant: QButtonVariant.primary,
                  loading: _submitting,
                  onPressed: _submitting ? null : _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final result = await ref
        .read(engagementRepositoryProvider)
        .report(
          entityType: widget.entityType,
          entityId: widget.entityId,
          reason: _reason,
          description: _detail.text,
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    final Failure? failure = result.failureOrNull;
    final AppLocalizations l10n = AppLocalizations.of(context);
    QSnackbar.show(
      context,
      message: failure == null
          ? l10n.reportSubmitted
          : ErrorMessages.of(failure).title,
      variant: failure == null
          ? QSnackbarVariant.success
          : QSnackbarVariant.danger,
    );
    Navigator.of(context).pop();
  }

  String _reasonLabel(AppLocalizations l10n, ReportReason r) => switch (r) {
    ReportReason.spam => l10n.reportReasonSpam,
    ReportReason.harassment => l10n.reportReasonHarassment,
    ReportReason.hateSpeech => l10n.reportReasonHateSpeech,
    ReportReason.violence => l10n.reportReasonViolence,
    ReportReason.sexualContent => l10n.reportReasonSexualContent,
    ReportReason.selfHarm => l10n.reportReasonSelfHarm,
    ReportReason.misinformation => l10n.reportReasonMisinformation,
    ReportReason.copyright => l10n.reportReasonCopyright,
    ReportReason.impersonation => l10n.reportReasonImpersonation,
    ReportReason.other => l10n.reportReasonOther,
  };
}
