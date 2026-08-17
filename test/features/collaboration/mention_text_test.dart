import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/collaboration/presentation/mention_text.dart';
import 'package:qalam_mobile/shared/domain/limits.dart';

/// The display↔raw translation P-2 rests on (`platfrom/docs/48` §5.1).
///
/// These are the assertions that stop the two halves of the feature drifting apart:
/// the composer writes `@<uuid>` into a body and the thread reads `@<uuid>` back out
/// of one, and if this file's idea of what a mention looks like ever differs from
/// `comment.service.ts`'s regex, one side notifies people the other never showed.
///
/// They are deliberately the same cases as web's `mention-text.spec.ts` — the two
/// clients write bodies the other has to render, so a behaviour that holds on one and
/// not the other is a defect on the client that did not change.
const MentionCandidate farheen = MentionCandidate(
  id: '550e8400-e29b-41d4-a716-446655440000',
  username: 'farheen',
  penName: 'Farheen Q',
);
const MentionCandidate ali = MentionCandidate(
  id: '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
  username: 'ali',
  penName: 'Ali R',
);

void main() {
  group('findMentionTrigger', () {
    test('opens on an @ that starts a word', () {
      final MentionTrigger? trigger = findMentionTrigger('nice catch @far', 15);
      expect(trigger?.start, 11);
      expect(trigger?.query, 'far');
    });

    test('opens on a bare @, so a writer can browse the roster', () {
      expect(findMentionTrigger('nice @', 6)?.query, '');
    });

    test('does not open mid-word — an email address is not a mention', () {
      expect(findMentionTrigger('you@example.com', 11), isNull);
    });

    test('closes once the caret leaves the token', () {
      expect(findMentionTrigger('@farheen ', 9), isNull);
    });
  });

  group('filterMentionCandidates', () {
    const List<MentionCandidate> people = <MentionCandidate>[farheen, ali];

    test('matches on handle or pen name, case-insensitively', () {
      expect(filterMentionCandidates(people, 'FAR'), <MentionCandidate>[
        farheen,
      ]);
      expect(filterMentionCandidates(people, 'ali r'), <MentionCandidate>[ali]);
    });

    test('offers everyone for a bare @', () {
      expect(filterMentionCandidates(people, ''), people);
    });
  });

  group('insertMention', () {
    test('inserts the handle, not the id, and parks the caret past it', () {
      const String text = 'nice catch @far';
      final MentionInsertion result = insertMention(
        text,
        findMentionTrigger(text, 15)!,
        farheen,
      );

      expect(result.text, 'nice catch @farheen ');
      expect(result.text.contains(farheen.id), isFalse);
      // Caret outside the token → the panel does not reopen on the person just chosen.
      expect(findMentionTrigger(result.text, result.caret), isNull);
    });

    test('does not double the space when mentioning mid-sentence', () {
      const String text = 'ask @fa about the ending';
      final MentionInsertion result = insertMention(
        text,
        findMentionTrigger(text, 7)!,
        farheen,
      );

      expect(result.text, 'ask @farheen about the ending');
      expect(findMentionTrigger(result.text, result.caret), isNull);
    });
  });

  group('toRawCommentBody', () {
    test('rewrites a selected handle to @<uuid> and reports the id', () {
      final RawCommentBody raw = toRawCommentBody(
        'nice catch @farheen',
        <MentionCandidate>[farheen],
      );

      expect(raw.body, 'nice catch @${farheen.id}');
      expect(raw.mentions, <String>[farheen.id]);
      // The server's own regex must find the same thing in the same body.
      expect(
        mentionUuidPattern.allMatches(raw.body).map((Match m) => m[1]).toList(),
        <String>[farheen.id],
      );
    });

    test('leaves a handle never picked from the typeahead as plain text', () {
      final RawCommentBody raw = toRawCommentBody(
        'what about @someone_else',
        <MentionCandidate>[farheen],
      );

      expect(raw.body, 'what about @someone_else');
      expect(raw.mentions, isEmpty);
    });

    test('handles two different people in one comment', () {
      final RawCommentBody raw = toRawCommentBody(
        '@farheen and @ali — thoughts?',
        <MentionCandidate>[farheen, ali],
      );

      expect(raw.body, '@${farheen.id} and @${ali.id} — thoughts?');
      expect(raw.mentions, <String>[farheen.id, ali.id]);
    });

    test('deduplicates a person mentioned twice', () {
      expect(
        toRawCommentBody('@farheen and @farheen', <MentionCandidate>[
          farheen,
        ]).mentions,
        <String>[farheen.id],
      );
    });
  });

  group('pruneMentions', () {
    test('drops a mention the writer has deleted', () {
      expect(pruneMentions('nice catch', <MentionCandidate>[farheen]), isEmpty);
    });

    test('drops one edited mid-handle rather than leaving a stale id', () {
      expect(
        pruneMentions('nice catch @farhee', <MentionCandidate>[farheen]),
        isEmpty,
      );
    });

    test('keeps one that is still there', () {
      expect(
        pruneMentions('nice catch @farheen', <MentionCandidate>[farheen, ali]),
        <MentionCandidate>[farheen],
      );
    });
  });

  group('rawCommentBodyLength', () {
    test('counts the id, not the handle — what the server enforces on', () {
      expect('@farheen'.length, 8);
      expect(rawCommentBodyLength('@farheen', <MentionCandidate>[farheen]), 37);
    });

    test('catches a body that only exceeds the limit once ids are substituted', () {
      // Visible text is comfortably under; the raw body is not. This is the case a
      // visible-character counter would wave through and the server would reject.
      final String text =
          '${'x' * (Limits.storyCommentBodyMax - 20)} @farheen @ali';

      expect(text.length, lessThan(Limits.storyCommentBodyMax));
      expect(
        exceedsCommentBodyLimit(text, <MentionCandidate>[farheen, ali]),
        isTrue,
      );
    });

    test('does not flag a body whose unresolved handles stay short', () {
      final String text =
          '${'x' * (Limits.storyCommentBodyMax - 20)} @nobody_here';
      expect(
        exceedsCommentBodyLimit(text, <MentionCandidate>[farheen]),
        isFalse,
      );
    });

    test('mirrors the AF6 cap, not the engagement one', () {
      // A collaboration body allows 5,000; a piece comment allows 2,000. Reading the
      // wrong constant here would reject half of a legal review note.
      expect(Limits.storyCommentBodyMax, 5000);
      expect(Limits.commentMaxLength, 2000);
    });
  });

  group('segmentCommentBody', () {
    test('splits a stored body into text and mention runs', () {
      final List<BodySegment> segments = segmentCommentBody(
        'hi @${farheen.id} and @${ali.id}!',
      );

      expect(segments.map((BodySegment s) => s.isMention).toList(), <bool>[
        false,
        true,
        false,
        true,
        false,
      ]);
      expect(segments[1].userId, farheen.id);
      expect(segments[3].userId, ali.id);
      expect(segments[4].value, '!');
    });

    test('leaves a body with no mentions as a single run', () {
      final List<BodySegment> segments = segmentCommentBody('just prose');
      expect(segments, hasLength(1));
      expect(segments.single.value, 'just prose');
    });

    test('round-trips what the composer produced', () {
      final RawCommentBody raw = toRawCommentBody(
        '@farheen look here',
        <MentionCandidate>[farheen],
      );
      final List<BodySegment> segments = segmentCommentBody(raw.body);

      expect(segments.first.userId, farheen.id);
      expect(segments.last.value, ' look here');
    });
  });
}
