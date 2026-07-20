/// Review session entity (AF6) — the publication review workflow state for a story
/// (`GET /stories/{id}/review`). The server owns the state machine (draft → in_review
/// → approved / changes_requested → published); the client renders it and drives the
/// request / approve / request-changes actions the policy engine authorizes.
library;

import '../../../../core/utils/typedefs.dart';
import 'collaboration_enums.dart';

class ReviewSession {
  const ReviewSession({
    required this.id,
    required this.storyId,
    required this.state,
    this.requestedBy,
    this.requestedByName,
    this.reviewerId,
    this.reviewerName,
    this.notes,
    this.requestedAt,
    this.decidedAt,
  });

  final String id;
  final String storyId;
  final String state;
  final String? requestedBy;
  final String? requestedByName;
  final String? reviewerId;
  final String? reviewerName;
  final String? notes;
  final DateTime? requestedAt;
  final DateTime? decidedAt;

  bool get isInReview => state == ReviewState.inReview;
  bool get isApproved => state == ReviewState.approved;
  bool get isChangesRequested => state == ReviewState.changesRequested;
  bool get isPublished => state == ReviewState.published;

  factory ReviewSession.fromJson(Json json) => ReviewSession(
    id: json['id'] as String? ?? '',
    storyId: json['storyId'] as String? ?? '',
    state: json['state'] as String? ?? ReviewState.draft,
    requestedBy: json['requestedBy'] as String?,
    requestedByName: json['requestedByName'] as String?,
    reviewerId: json['reviewerId'] as String?,
    reviewerName: json['reviewerName'] as String?,
    notes: json['notes'] as String? ?? json['note'] as String?,
    requestedAt: _date(json['requestedAt']),
    decidedAt: _date(json['decidedAt']),
  );
}

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;
