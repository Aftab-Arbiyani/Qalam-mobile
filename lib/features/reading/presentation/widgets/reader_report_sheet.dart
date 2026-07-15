/// Report-content sheet (docs/40 §21) — reason chips + optional detail, submitted
/// to `POST /reports` via the engagement controller. Calm, non-blaming copy.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/error_messages.dart';
import '../../../../core/error/failure.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../../../shared/widgets/cards/q_chip.dart';
import '../../../../shared/widgets/feedback/q_snackbar.dart';
import '../controllers/engagement_controller.dart';

class ReaderReportSheet extends ConsumerStatefulWidget {
  const ReaderReportSheet({required this.pieceId, super.key});

  final String pieceId;

  @override
  ConsumerState<ReaderReportSheet> createState() => _ReaderReportSheetState();
}

class _ReaderReportSheetState extends ConsumerState<ReaderReportSheet> {
  ReportReason _reason = ReportReason.spam;
  final TextEditingController _detail = TextEditingController();
  bool _submitting = false;

  static const List<(ReportReason, String)> _reasons = <(ReportReason, String)>[
    (ReportReason.spam, 'Spam'),
    (ReportReason.harassment, 'Harassment'),
    (ReportReason.hateSpeech, 'Hate speech'),
    (ReportReason.violence, 'Violence'),
    (ReportReason.sexualContent, 'Sexual content'),
    (ReportReason.selfHarm, 'Self-harm'),
    (ReportReason.misinformation, 'Misinformation'),
    (ReportReason.copyright, 'Copyright'),
    (ReportReason.impersonation, 'Impersonation'),
    (ReportReason.other, 'Something else'),
  ];

  @override
  void dispose() {
    _detail.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final Failure? failure = await ref
        .read(engagementControllerProvider(widget.pieceId).notifier)
        .report(reason: _reason, description: _detail.text);
    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.of(context).pop();
    if (failure == null) {
      QSnackbar.show(
        context,
        message: 'Thank you. Our team will take a look.',
        variant: QSnackbarVariant.success,
      );
    } else {
      QSnackbar.show(
        context,
        message: ErrorMessages.of(failure).title,
        variant: QSnackbarVariant.danger,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          QSpacing.s4,
          QSpacing.s2,
          QSpacing.s4,
          QSpacing.s5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Report this piece', style: theme.textTheme.titleMedium),
            Gap.v1,
            Text(
              'Tell us what’s wrong. Reports are private.',
              style: theme.textTheme.bodyMedium,
            ),
            Gap.v4,
            Wrap(
              spacing: QSpacing.s2,
              runSpacing: QSpacing.s2,
              children: <Widget>[
                for (final (ReportReason reason, String label) option
                    in _reasons)
                  QChip(
                    label: option.$2,
                    tone: _reason == option.$1
                        ? QChipTone.accent
                        : QChipTone.neutral,
                    onTap: () => setState(() => _reason = option.$1),
                  ),
              ],
            ),
            Gap.v4,
            TextField(
              controller: _detail,
              maxLines: 3,
              maxLength: 1000,
              decoration: const InputDecoration(
                hintText: 'Add any details (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            Gap.v3,
            QButton(
              label: 'Submit report',
              variant: QButtonVariant.primary,
              block: true,
              loading: _submitting,
              onPressed: _submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
