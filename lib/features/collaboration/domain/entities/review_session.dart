/// Review session entity (AF6) — the publication review workflow state for a story
/// (`GET /stories/{id}/review`). The server owns the state machine (draft → in_review
/// → approved / changes_requested → published); the client renders it and drives the
/// request / approve / request-changes actions the policy engine authorizes.
library;

import '../../../../core/utils/typedefs.dart';
import 'collaboration_enums.dart';

/// Mirrors `ReviewDto` field for field. It previously read `requestedBy` and
/// `requestedAt`, which the wire calls `requestedById` and `submittedAt`, so both
/// were permanently null; and it ignored `decision`, the field that says *why* a
/// review left `in_review` (defect **P-6**, `docs/56` §2.2). There are no
/// `*Name` fields on the wire — the DTO carries ids only, like `InvitationDto`.
class ReviewSession {
  const ReviewSession({
    required this.id,
    required this.storyId,
    required this.state,
    this.requestedById,
    this.reviewerId,
    this.decision,
    this.notes,
    this.submittedAt,
    this.decidedAt,
  });

  final String id;
  final String storyId;
  final String state;
  final String? requestedById;
  final String? reviewerId;

  /// `approve` / `request_changes` / `reject` — null until a reviewer decides.
  final String? decision;
  final String? notes;
  final DateTime? submittedAt;
  final DateTime? decidedAt;

  bool get isInReview => state == ReviewState.inReview;
  bool get isApproved => state == ReviewState.approved;
  bool get isChangesRequested => state == ReviewState.changesRequested;
  bool get isPublished => state == ReviewState.published;

  factory ReviewSession.fromJson(Json json) => ReviewSession(
    id: json['id'] as String? ?? '',
    storyId: json['storyId'] as String? ?? '',
    state: json['state'] as String? ?? ReviewState.draft,
    requestedById: json['requestedById'] as String?,
    reviewerId: json['reviewerId'] as String?,
    decision: json['decision'] as String?,
    notes: json['notes'] as String?,
    submittedAt: _date(json['submittedAt']),
    decidedAt: _date(json['decidedAt']),
  );
}

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;
