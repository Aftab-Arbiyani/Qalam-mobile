/// Presence bar (AF6) — a compact row of collaborator avatars for a story with a
/// "someone is typing" hint. Non-critical chrome: while the roster loads or fails it
/// renders nothing (an empty box), never an error surface.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../profile/presentation/widgets/actor_identity.dart';
import '../../domain/entities/presence_entry.dart';
import '../providers/collaboration_providers.dart';

class PresenceBar extends ConsumerWidget {
  const PresenceBar({required this.storyId, this.maxAvatars = 5, super.key});

  final String storyId;
  final int maxAvatars;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PresenceEntry>> async = ref.watch(
      storyPresenceProvider(storyId),
    );
    return async.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (List<PresenceEntry> entries) {
        if (entries.isEmpty) return const SizedBox.shrink();
        final List<PresenceEntry> shown = entries
            .take(maxAvatars)
            .toList(growable: false);
        final int overflow = entries.length - shown.length;
        final Iterable<PresenceEntry> typing = entries.where(
          (PresenceEntry e) => e.isTyping,
        );
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: QSpacing.s4,
            vertical: QSpacing.s2,
          ),
          child: Row(
            children: <Widget>[
              for (final PresenceEntry entry in shown)
                Padding(
                  padding: const EdgeInsets.only(right: QSpacing.s1),
                  child: Semantics(
                    // Resolved by id (B3) — `PresenceDto` carries no name, so
                    // `entry.label` fell through to the raw uuid.
                    label:
                        '${actorDisplayName(ref, entry.userId)} '
                        '(${entry.state})',
                    child: ActorAvatar(userId: entry.userId, size: 28),
                  ),
                ),
              if (overflow > 0)
                Padding(
                  padding: const EdgeInsets.only(left: QSpacing.s1),
                  child: Text(
                    '+$overflow',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              const Spacer(),
              if (typing.isNotEmpty)
                Text(
                  _typingLabel(ref, typing.toList(growable: false)),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
            ],
          ),
        );
      },
    );
  }

  String _typingLabel(WidgetRef ref, List<PresenceEntry> typing) {
    if (typing.length == 1) {
      return '${actorDisplayName(ref, typing.first.userId)} is typing…';
    }
    return '${typing.length} people are typing…';
  }
}
