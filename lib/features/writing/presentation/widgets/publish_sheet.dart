/// The publish / schedule sheet (M4; docs/40 §47 M6). Confirms visibility, gates
/// on client-side publish validation (a UX mirror of the server's `PIECE_INCOMPLETE`
/// rule), and offers Publish-now or Schedule-for-later. It only collects intent and
/// calls [CurrentDraftController]; the actual publish/schedule queues through the
/// sync engine (works offline). Returns true if an action was taken.
library;

// Hide Material's Visibility widget — this file uses the domain `Visibility` enum.
import 'package:flutter/material.dart' hide Visibility;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/domain/enums.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/util/relative_time.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../domain/value_objects/draft_validation.dart';
import '../controllers/current_draft_controller.dart';
import '../controllers/editor_state.dart';

class PublishSheet extends ConsumerStatefulWidget {
  const PublishSheet({required this.routeId, super.key});

  final String routeId;

  @override
  ConsumerState<PublishSheet> createState() => _PublishSheetState();
}

class _PublishSheetState extends ConsumerState<PublishSheet> {
  DateTime? _scheduledAt;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final EditorState? st = ref
        .watch(currentDraftControllerProvider(widget.routeId))
        .asData
        ?.value;
    if (st == null) return const SizedBox.shrink();
    final DraftValidation validation = st.validation;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        QSpacing.s5,
        QSpacing.s2,
        QSpacing.s5,
        QSpacing.s5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            validation.canPublish ? 'Ready to publish?' : 'Before you publish',
            style: theme.textTheme.titleLarge,
          ),
          Gap.v4,
          if (!validation.canPublish)
            _MissingList(validation: validation, tokens: tokens)
          else ...<Widget>[
            _VisibilityNote(visibility: st.draft.visibility, tokens: tokens),
            Gap.v4,
            if (_scheduledAt != null)
              Padding(
                padding: const EdgeInsets.only(bottom: QSpacing.s3),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.schedule, size: 16, color: tokens.colors.accent),
                    const SizedBox(width: QSpacing.s2),
                    Expanded(
                      child: Text(
                        'Scheduled for ${readableDateTime(_scheduledAt!)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: _busy ? null : _pickSchedule,
                      child: const Text('Change'),
                    ),
                  ],
                ),
              ),
            QButton(
              label: _scheduledAt == null ? 'Publish now' : 'Schedule',
              variant: QButtonVariant.primary,
              block: true,
              loading: _busy,
              onPressed: _busy ? null : _confirm,
            ),
            Gap.v2,
            if (_scheduledAt == null)
              QButton(
                label: 'Schedule for later',
                variant: QButtonVariant.ghost,
                block: true,
                icon: Icons.schedule,
                onPressed: _busy ? null : _pickSchedule,
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickSchedule() async {
    final DateTime now = DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _scheduledAt ?? now.add(const Duration(hours: 1)),
      ),
    );
    if (time == null || !mounted) return;
    final DateTime chosen = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (!chosen.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a time in the future.')),
      );
      return;
    }
    setState(() => _scheduledAt = chosen);
  }

  Future<void> _confirm() async {
    setState(() => _busy = true);
    final CurrentDraftController notifier = ref.read(
      currentDraftControllerProvider(widget.routeId).notifier,
    );
    final DateTime? at = _scheduledAt;
    if (at == null) {
      await notifier.publish();
    } else {
      await notifier.schedule(at);
    }
    if (mounted) Navigator.of(context).pop(true);
  }
}

class _MissingList extends StatelessWidget {
  const _MissingList({required this.validation, required this.tokens});
  final DraftValidation validation;
  final QTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Add these before publishing:',
          style: TextStyle(color: tokens.colors.textSecondary),
        ),
        Gap.v3,
        for (final PublishRequirement r in validation.missing)
          Padding(
            padding: const EdgeInsets.only(bottom: QSpacing.s2),
            child: Row(
              children: <Widget>[
                Icon(Icons.circle, size: 6, color: tokens.colors.danger),
                const SizedBox(width: QSpacing.s2),
                Text(_label(r)),
              ],
            ),
          ),
      ],
    );
  }

  String _label(PublishRequirement r) => switch (r) {
    PublishRequirement.title => 'A title',
    PublishRequirement.language => 'A language',
    PublishRequirement.genre => 'A genre',
    PublishRequirement.content => 'Some content',
  };
}

class _VisibilityNote extends StatelessWidget {
  const _VisibilityNote({required this.visibility, required this.tokens});
  final Visibility visibility;
  final QTokens tokens;

  @override
  Widget build(BuildContext context) {
    final String note = switch (visibility) {
      Visibility.public => 'Anyone can find and read this.',
      Visibility.unlisted => 'Only people with the link can read this.',
      Visibility.private => 'Only you can read this.',
    };
    return Row(
      children: <Widget>[
        Icon(
          Icons.visibility_outlined,
          size: 16,
          color: tokens.colors.textMuted,
        ),
        const SizedBox(width: QSpacing.s2),
        Expanded(
          child: Text(
            note,
            style: TextStyle(color: tokens.colors.textSecondary),
          ),
        ),
      ],
    );
  }
}
