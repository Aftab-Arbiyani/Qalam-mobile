/// Role badge (AF6) — a small pill showing a collaborator's [StoryRole], tinted by
/// privilege (owner emphasised). Presentation-only; reads its label from the domain
/// label helpers so it never renders a raw wire string.
library;

import 'package:flutter/material.dart';

import '../../domain/entities/collaboration_enums.dart';
import '../domain_labels.dart';

class RoleBadge extends StatelessWidget {
  const RoleBadge({required this.role, super.key});

  final String role;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool emphasised =
        role == StoryRole.owner || role == StoryRole.coAuthor;
    final Color bg = emphasised
        ? cs.primaryContainer
        : cs.surfaceContainerHighest;
    final Color fg = emphasised ? cs.onPrimaryContainer : cs.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        roleLabel(role),
        style: theme.textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
