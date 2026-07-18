/// Interactive navigation between linked entities (AF4). Maps a backend
/// [NavigationTarget] to an in-app route via route NAMES only (docs 40 §7.3 —
/// cross-feature coupling is allowed via the router, never by importing another
/// feature). Graph-node targets are handled in-place by the explorer (a detail sheet),
/// so they return false here (the caller shows the sheet instead).
library;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../domain/entities/retrieval.dart';

/// Navigate to [target]. Returns true if a route was pushed; false when the caller
/// should handle it locally (e.g. open a graph-node detail sheet).
bool navigateToTarget(BuildContext context, NavigationTarget target) {
  switch (target.kind) {
    case 'piece':
    case 'chapter':
      if (target.ref.isEmpty) return false;
      context.push(Routes.piecePath(target.ref));
      return true;
    case 'author':
      if (target.ref.isEmpty) return false;
      context.push(Routes.userProfilePath(target.ref));
      return true;
    case 'genre':
    case 'tag':
      context.push(Routes.discover);
      return true;
    default:
      // graph_node / explorer / unknown → handled in-place by the caller.
      return false;
  }
}
