/// The inbox status filter (docs/41 §37 — "filterable by status"). The backend
/// `?status=` accepts unread / read / archived; omitting it returns everything,
/// which [all] models (a null wire status). Used as the notifications controller's
/// Riverpod family key and as the per-filter cache-key suffix, so each filter
/// keeps its own cached first page.
library;

import '../../../../shared/domain/enums.dart';

enum NotificationFilter {
  all(null, 'all'),
  unread(NotificationStatus.unread, 'unread'),
  read(NotificationStatus.read, 'read'),
  archived(NotificationStatus.archived, 'archived');

  const NotificationFilter(this.status, this.cacheSuffix);

  /// The wire `?status=` value, or null to omit the param (all).
  final NotificationStatus? status;

  /// Stable cache-key / family-identity suffix.
  final String cacheSuffix;

  /// Whether an item with [itemStatus] still belongs in this filter — used to
  /// drop a row optimistically when an action moves it out of the current view
  /// (e.g. marking read removes it from the Unread filter).
  bool matches(NotificationStatus itemStatus) =>
      status == null || status == itemStatus;
}
