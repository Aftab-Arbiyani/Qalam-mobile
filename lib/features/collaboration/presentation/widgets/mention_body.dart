/// A stored comment body, with its `@<uuid>` mentions rendered as names
/// (P-2, `platfrom/docs/48` §5.1).
///
/// **This is the other half of composing a mention, not a follow-up to it.** The
/// wire format keeps the mention as an id inside the body precisely so the name can
/// be resolved fresh — which means any surface that prints a body without resolving
/// shows 37 characters of hex to a human. Shipping the composer without this would
/// put raw UUIDs in front of real users, reintroducing in a new place the exact
/// defect **B3** had just finished removing.
///
/// The lookup is B3's [actorProfileProvider] (`GET /users/by-id/:id`), keyed per
/// user and `keepAlive`, so a thread where three people mention each other twenty
/// times costs three requests — and they are the same three the author rows already
/// resolved, so in practice it costs nothing extra.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/util/short_actor_id.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/presentation/controllers/actor_profile_controller.dart';
import '../mention_text.dart';

class MentionBody extends ConsumerWidget {
  const MentionBody({required this.body, this.style, super.key});

  final String body;
  final TextStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<BodySegment> segments = segmentCommentBody(body);
    // The overwhelmingly common case — no mention at all — stays an ordinary Text.
    if (segments.length == 1 && !segments.first.isMention) {
      return Text(body, style: style);
    }

    final ThemeData theme = Theme.of(context);
    final TextStyle base =
        style ?? theme.textTheme.bodyMedium ?? const TextStyle();

    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          for (final BodySegment segment in segments)
            if (segment.isMention)
              _mentionSpan(ref, segment.userId!, base, theme)
            else
              TextSpan(text: segment.value, style: base),
        ],
      ),
    );
  }

  /// One resolved mention.
  ///
  /// Shows `@handle` — the same token the composer inserts, so a mention reads
  /// identically to the person who wrote it and the person who reads it, and a
  /// writer who retypes one from memory gets a real mention rather than plain text.
  ///
  /// **An unresolvable id degrades to B3's floor, never below it.** A deleted
  /// account, a private profile the viewer cannot see, or a failed lookup renders
  /// the short-id fragment — recognisably an id rather than a name — and never a
  /// full UUID and never a fabricated name. The semantics label carries the pen
  /// name, which is the fuller identity a screen reader should hear.
  InlineSpan _mentionSpan(
    WidgetRef ref,
    String userId,
    TextStyle base,
    ThemeData theme,
  ) {
    final Profile? profile = ref
        .watch(actorProfileProvider(userId))
        .asData
        ?.value;
    final String? username = profile?.username;
    final String label = username != null && username.isNotEmpty
        ? username
        : shortActorId(userId);
    final String penName = profile?.penName ?? '';

    return TextSpan(
      text: '@$label',
      style: base.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
      semanticsLabel: penName.trim().isNotEmpty
          ? 'mention of ${penName.trim()}'
          : 'mention of $label',
    );
  }
}
