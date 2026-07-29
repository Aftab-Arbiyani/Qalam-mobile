/// Regression guard for defects **C-1** and **C-2** (`docs/56` §2.1).
///
/// **C-1.** `GET /stories/:storyId/capabilities` answers `CapabilitiesDto` —
/// `{storyId, capabilities: CapabilityDto[]}` — an object wrapping an **array**.
/// `StoryCapabilities.fromJson` used to iterate the top-level object as if it were an
/// `{action: decision}` map, so `storyId` (a String) and `capabilities` (a List) were
/// both skipped and the map came out EMPTY: `allows()` false for every action, so every
/// `CapabilityGate` in the feature rendered its locked fallback on every story, for the
/// owner included. HTTP 200, no exception — nothing surfaced it.
///
/// **C-2.** The action set is chosen server-side (`COLLABORATION_CAPABILITY_ACTIONS` →
/// `PolicyEngineService.explain`); the endpoint takes no query or body. Three actions the
/// publishing screen gates on were NOT in that set, so no client could decide them and all
/// five gates rendered nothing. The backend fix appended them; these tests pin the set the
/// client may rely on, so a future divergence is loud rather than silent.
///
/// Asserts the wire shape, not the mobile abstraction — the payloads below are the real
/// `toCapabilityDtos` output.
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/collaboration_enums.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/policy_capability.dart';

/// The real `CapabilitiesDto` payload for an owner, as `collaboration.mappers.ts`
/// (`toCapabilityDtos`) emits it: an array, each element carrying its own `action`.
Map<String, dynamic> _ownerPayload() => <String, dynamic>{
  'storyId': '019f9247-c8a6-759f-afa2-cb4ca5fe6ebe',
  'capabilities': <dynamic>[
    <String, dynamic>{
      'action': 'story.view',
      'effect': 'allow',
      'allowed': true,
      'reason': 'story_role_satisfied',
      'obligations': <dynamic>[],
    },
    <String, dynamic>{
      'action': 'story.comment',
      'effect': 'allow',
      'allowed': true,
      'reason': 'story_role_satisfied',
      'obligations': <dynamic>[],
    },
    <String, dynamic>{
      'action': 'suggestion.resolve',
      'effect': 'allow',
      'allowed': true,
      'reason': 'story_role_satisfied',
      'obligations': <dynamic>[],
    },
    <String, dynamic>{
      'action': 'story.suggest',
      'effect': 'deny',
      'allowed': false,
      'reason': 'trust_muted',
      'obligations': <dynamic>[],
    },
    <String, dynamic>{
      'action': 'story.manage_members',
      'effect': 'conditional_access',
      'allowed': true,
      'reason': 'entitlement_required',
      'obligations': <dynamic>['requires_entitlement'],
    },
  ],
};

void main() {
  group('StoryCapabilities decodes CapabilitiesDto (C-1)', () {
    test('keys the map by each element\'s own action', () {
      final StoryCapabilities caps = StoryCapabilities.fromJson(_ownerPayload());

      // The bug: this map was empty, so every one of these was false.
      expect(caps.capabilities, hasLength(5));
      expect(caps.allows(PolicyAction.storyView), isTrue);
      expect(caps.allows(PolicyAction.storyComment), isTrue);
      expect(caps.allows(PolicyAction.suggestionResolve), isTrue);
    });

    test('reads storyId from the envelope, not as a capability', () {
      final StoryCapabilities caps = StoryCapabilities.fromJson(_ownerPayload());

      expect(caps.storyId, '019f9247-c8a6-759f-afa2-cb4ca5fe6ebe');
      // `storyId` is a sibling of `capabilities`, never an action key.
      expect(caps.capabilities.containsKey('storyId'), isFalse);
    });

    test('carries effect, reason and obligations through', () {
      final StoryCapabilities caps = StoryCapabilities.fromJson(_ownerPayload());
      final PolicyCapability manage = caps.capabilityFor(
        PolicyAction.storyManageMembers,
      );

      expect(manage.effect, PolicyEffect.conditionalAccess);
      expect(manage.isConditional, isTrue);
      expect(manage.obligations, <String>['requires_entitlement']);
      expect(manage.reason, 'entitlement_required');
    });

    test('a server deny stays denied — the fix does not fail open', () {
      final StoryCapabilities caps = StoryCapabilities.fromJson(_ownerPayload());

      expect(caps.allows(PolicyAction.storySuggest), isFalse);
      expect(caps.capabilityFor(PolicyAction.storySuggest).reason, 'trust_muted');
    });

    test('an action absent from the payload default-denies', () {
      final StoryCapabilities caps = StoryCapabilities.fromJson(_ownerPayload());
      final PolicyCapability absent = caps.capabilityFor(
        PolicyAction.commentDelete,
      );

      expect(absent.allowed, isFalse);
      expect(absent.effect, PolicyEffect.deny);
      expect(absent.reason, 'no_policy');
    });

    test('readOnly stays fail-closed', () {
      expect(StoryCapabilities.readOnly.allows(PolicyAction.storyComment), isFalse);
      expect(StoryCapabilities.readOnly.allows(PolicyAction.storyView), isFalse);
    });

    test('tolerates a malformed payload without throwing', () {
      // A capability with no `action` cannot be keyed; a non-map element is skipped.
      final StoryCapabilities caps = StoryCapabilities.fromJson(<String, dynamic>{
        'storyId': 's1',
        'capabilities': <dynamic>[
          'not-a-map',
          <String, dynamic>{'effect': 'allow', 'allowed': true},
        ],
      });

      expect(caps.capabilities, isEmpty);
      expect(caps.allows(PolicyAction.storyView), isFalse);
    });

    test('a missing capabilities key yields an empty, fail-closed map', () {
      final StoryCapabilities caps = StoryCapabilities.fromJson(
        <String, dynamic>{'storyId': 's1'},
      );

      expect(caps.capabilities, isEmpty);
      expect(caps.allows(PolicyAction.storyComment), isFalse);
    });
  });

  group('captured live payload', () {
    /// Copied verbatim from `GET /api/v1/stories/:id/capabilities` on a local
    /// backend (2026-07-28), owner viewing their own piece. Kept byte-for-byte so
    /// this test fails if the real shape ever moves — including `reason`, which is
    /// a human sentence on the wire, not a machine code.
    const String liveBody = '''
{"success":true,"data":{"storyId":"019fa830-4ca1-7598-9ba9-42aab0061e66","capabilities":[
{"action":"story.view","effect":"allow","allowed":true,"reason":"You own this resource.","obligations":[]},
{"action":"story.comment","effect":"allow","allowed":true,"reason":"You own this resource.","obligations":[]},
{"action":"story.suggest","effect":"allow","allowed":true,"reason":"You own this resource.","obligations":[]},
{"action":"story.invite","effect":"allow","allowed":true,"reason":"You own this resource.","obligations":[]},
{"action":"story.manage_members","effect":"allow","allowed":true,"reason":"You own this resource.","obligations":[]},
{"action":"story.manage_roles","effect":"allow","allowed":true,"reason":"You own this resource.","obligations":[]},
{"action":"comment.resolve","effect":"allow","allowed":true,"reason":"You own this resource.","obligations":[]},
{"action":"comment.delete","effect":"allow","allowed":true,"reason":"You own this resource.","obligations":[]},
{"action":"suggestion.resolve","effect":"allow","allowed":true,"reason":"You own this resource.","obligations":[]},
{"action":"story.edit","effect":"allow","allowed":true,"reason":"You own this resource.","obligations":[]},
{"action":"publication.publish","effect":"allow","allowed":true,"reason":"You own this resource.","obligations":[]},
{"action":"review.approve","effect":"allow","allowed":true,"reason":"You own this resource.","obligations":[]}]}}
''';

    test('an owner is allowed every action the server explains', () {
      final Map<String, dynamic> envelope =
          jsonDecode(liveBody) as Map<String, dynamic>;
      final StoryCapabilities caps = StoryCapabilities.fromJson(
        envelope['data'] as Map<String, dynamic>,
      );

      expect(caps.capabilities, hasLength(12));
      for (final String action in PolicyAction.serverExplained) {
        expect(
          caps.allows(action),
          isTrue,
          reason: 'owner should be allowed $action',
        );
      }
    });

    test('the live payload decides the three publishing gates (C-2 closed)', () {
      final Map<String, dynamic> envelope =
          jsonDecode(liveBody) as Map<String, dynamic>;
      final StoryCapabilities caps = StoryCapabilities.fromJson(
        envelope['data'] as Map<String, dynamic>,
      );

      // These three used to be absent from the response, so the publishing screen's
      // five gates default-denied for the owner too. They now carry a real verdict.
      for (final String action in <String>[
        PolicyAction.storyEdit,
        PolicyAction.publicationPublish,
        PolicyAction.reviewApprove,
      ]) {
        expect(caps.capabilities.containsKey(action), isTrue);
        expect(caps.allows(action), isTrue);
        expect(caps.capabilityFor(action).reason, isNot('no_policy'));
      }
    });
  });

  group('the mirror matches what the server explains (C-2)', () {
    test('serverExplained is exactly COLLABORATION_CAPABILITY_ACTIONS', () {
      // Mirrors `collaboration.constants.ts`, in its order. If the backend constant
      // changes, change this list with it — a gate keyed on an action absent from
      // the server's set silently default-denies.
      expect(PolicyAction.serverExplained, <String>[
        'story.view',
        'story.comment',
        'story.suggest',
        'story.invite',
        'story.manage_members',
        'story.manage_roles',
        'comment.resolve',
        'comment.delete',
        'suggestion.resolve',
        'story.edit',
        'publication.publish',
        'review.approve',
      ]);
    });

    test('every action constant on PolicyAction is explained', () {
      // There is no longer a second, unexplained list: a `PolicyAction` the server
      // does not decide would be a gate that renders nothing, which is the defect.
      expect(
        <String>[
          PolicyAction.storyView,
          PolicyAction.storyEdit,
          PolicyAction.storyComment,
          PolicyAction.storySuggest,
          PolicyAction.storyInvite,
          PolicyAction.storyManageMembers,
          PolicyAction.storyManageRoles,
          PolicyAction.commentResolve,
          PolicyAction.commentDelete,
          PolicyAction.suggestionResolve,
          PolicyAction.publicationPublish,
          PolicyAction.reviewApprove,
        ].where((String a) => !PolicyAction.serverExplained.contains(a)),
        isEmpty,
      );
    });
  });
}
