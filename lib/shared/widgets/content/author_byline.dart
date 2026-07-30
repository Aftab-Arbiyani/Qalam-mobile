/// Author byline (docs/41 §11.19) — avatar + pen name + `@handle` (bidi-isolated,
/// always LTR) + optional meta (relative time / read-time) and a trailing slot
/// (Follow / overflow). Reused by the feed card and the reading author area, so it
/// takes a resolved avatar URL and plain strings (no feature/entity coupling).
library;

import 'package:flutter/material.dart';

import '../../theme/q_tokens.dart';
import '../../theme/tokens/spacing_tokens.dart';
import '../media/q_avatar.dart';

class AuthorByline extends StatelessWidget {
  const AuthorByline({
    required this.name,
    required this.handle,
    this.avatarUrl,
    this.meta,
    this.avatarSize = 32,
    this.trailing,
    super.key,
  });

  final String name;
  final String handle;
  final String? avatarUrl;
  final String? meta;
  final double avatarSize;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final String secondLine = meta == null || meta!.isEmpty
        ? handle
        : '$handle · $meta';

    return Row(
      children: <Widget>[
        QAvatar(name: name, imageUrl: avatarUrl, size: avatarSize),
        Gap.h3,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge,
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  secondLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: tokens.colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...<Widget>[Gap.h2, trailing!],
      ],
    );
  }
}
