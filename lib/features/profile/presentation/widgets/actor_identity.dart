/// Rendering a person from a bare user id (B3, `platfrom/docs/45` §4).
///
/// Three thin renderers over ONE resolution ([actorProfileProvider]) rather than
/// a single fat widget, because the surfaces that need this already have their
/// own layouts: comments pair an avatar with an expanded name, the invitations
/// inbox interpolates the name into a sentence, and snackbars need a plain
/// string. Sharing the provider (not the layout) is what stops six screens from
/// each inventing their own lookup.
///
/// Every renderer falls back to [shortActorId] while the lookup is in flight and
/// if it fails — see `actor_profile_controller.dart` for why a failure is not an
/// error state on these surfaces.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../shared/util/short_actor_id.dart';
import '../../../../shared/widgets/media/q_avatar.dart';
import '../../domain/entities/profile.dart';
import '../controllers/actor_profile_controller.dart';

/// The display name for [userId] right now: the resolved pen name if it has
/// arrived, else the short-id fallback. Watches, so a caller inside `build`
/// re-renders when the lookup lands — use [readActorDisplayName] in a callback.
String actorDisplayName(WidgetRef ref, String? userId) {
  if (userId == null || userId.isEmpty) return shortActorId(userId);
  return _nameOf(ref.watch(actorProfileProvider(userId)).asData?.value, userId);
}

/// The same name, read once rather than watched — for an imperative string built
/// in a callback (a snackbar), where watching is illegal and a rebuild is
/// meaningless. The list the action came from has already resolved the profile,
/// so this is a cache hit in practice.
String readActorDisplayName(WidgetRef ref, String? userId) {
  if (userId == null || userId.isEmpty) return shortActorId(userId);
  return _nameOf(ref.read(actorProfileProvider(userId)).asData?.value, userId);
}

String _nameOf(Profile? profile, String userId) {
  final String? penName = profile?.penName;
  return penName != null && penName.isNotEmpty ? penName : shortActorId(userId);
}

/// The person's name as text. [format] wraps it when the surface needs a
/// sentence ("from Alice") rather than a bare name.
class ActorName extends ConsumerWidget {
  const ActorName({
    required this.userId,
    this.style,
    this.format,
    this.overflow = TextOverflow.ellipsis,
    super.key,
  });

  final String? userId;
  final TextStyle? style;
  final String Function(String name)? format;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String name = actorDisplayName(ref, userId);
    return Text(
      format == null ? name : format!(name),
      style: style,
      overflow: overflow,
    );
  }
}

/// The person's avatar — their real image once resolved, initials of the
/// fallback label until then.
class ActorAvatar extends ConsumerWidget {
  const ActorAvatar({required this.userId, this.size = 32, super.key});

  final String? userId;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String name = actorDisplayName(ref, userId);
    final Profile? profile = userId == null || userId!.isEmpty
        ? null
        : ref.watch(actorProfileProvider(userId!)).asData?.value;
    return QAvatar(
      name: name,
      imageUrl: ref
          .watch(mediaUrlBuilderProvider)
          .urlForKey(profile?.avatarKey),
      size: size,
    );
  }
}

/// Avatar + name in a row — the common case (a member row, a comment header).
class ActorIdentity extends StatelessWidget {
  const ActorIdentity({
    required this.userId,
    this.avatarSize = 32,
    this.nameStyle,
    this.gap = 8,
    super.key,
  });

  final String? userId;
  final double avatarSize;
  final TextStyle? nameStyle;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        ActorAvatar(userId: userId, size: avatarSize),
        SizedBox(width: gap),
        Expanded(
          child: ActorName(userId: userId, style: nameStyle),
        ),
      ],
    );
  }
}
