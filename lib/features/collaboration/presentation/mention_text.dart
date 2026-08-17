/// The text layer of composing an @mention (P-2, `platfrom/docs/48` §5.1).
///
/// **The wire format, and the whole reason this file exists.** A mention is stored
/// as `@<uuid>` *inside the comment body* — `CommentService.parseMentions`
/// re-derives `mentions[]` from the body with its own regex
/// (`comment.service.ts:46`), so the body **is** the mention. That was chosen
/// because it is rename-proof: the stored token points at a *person*, and the name
/// is resolved fresh at render time rather than frozen into prose that goes stale.
///
/// The cost is that a raw body is unreadable to a human — 37 characters of hex
/// where a name belongs. So the composer never shows one. A writer types and edits
/// **handles** (`@farheen`), and this file is the single translation between what
/// they see and what the server stores:
///
/// ```
///   display   "nice catch @farheen"                                 ← what the TextField holds
///   raw       "nice catch @550e8400-e29b-41d4-a716-446655440000"    ← what POSTs, and what counts
/// ```
///
/// **Why a handle and not a pen name.** The reverse mapping has to be total, and a
/// pen name breaks it twice: pen names are not unique (two collaborators called
/// "Ali" would be indistinguishable when turning display text back into ids) and
/// they contain spaces (so there is no token boundary to find one by). A username
/// is unique platform-wide and drawn from `[a-z0-9_]` ([Patterns.username]), which
/// makes both the tokenizer and the reverse map exact. It is also what people type.
///
/// **Kept deliberately in step with web's `mention-text.ts`.** Same regexes, same
/// function names, same round-trip — the two clients write bodies the other has to
/// render, so a divergence here is a defect on the client that did not change.
library;

import '../../../shared/domain/limits.dart';

/// Characters a username can contain — the token boundary for a typed handle.
final RegExp _handleToken = RegExp(r'@([A-Za-z0-9_]+)');

/// A stored mention: `@` + a user uuid. Deliberately identical to the server's
/// `MENTION_UUID_RE` (`comment.service.ts:46`) and to web's copy — if these
/// disagree, one client counts and renders a set of mentions the server does not
/// notify, or the other way round.
final RegExp mentionUuidPattern = RegExp(
  r'@([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})',
  caseSensitive: false,
);

final RegExp _wordChar = RegExp(r'[A-Za-z0-9_]');
final RegExp _space = RegExp(r'\s');

/// A person the composer may insert — the id it must write, plus what the writer
/// sees and searches on.
class MentionCandidate {
  const MentionCandidate({
    required this.id,
    required this.username,
    required this.penName,
    this.avatarKey,
  });

  final String id;
  final String username;
  final String penName;

  /// S3 key, never a URL — the typeahead row draws it through the media builder.
  final String? avatarKey;

  @override
  bool operator ==(Object other) =>
      other is MentionCandidate && other.id == id && other.username == username;

  @override
  int get hashCode => Object.hash(id, username);
}

/// An `@…` being typed at the caret: where it starts, and what follows the `@`.
class MentionTrigger {
  const MentionTrigger({required this.start, required this.query});

  /// Index of the `@`.
  final int start;

  /// Text between the `@` and the caret — may be empty, which is a bare `@`.
  final String query;
}

/// The `@…` the caret currently sits inside, or null if the writer is not
/// mentioning anyone.
///
/// A trigger requires the `@` to open a word: at the start of the text, or after
/// whitespace. That is what keeps an email address from opening the typeahead on
/// every keystroke.
MentionTrigger? findMentionTrigger(String text, int caret) {
  int index = caret.clamp(0, text.length);
  while (index > 0 && _wordChar.hasMatch(text[index - 1])) {
    index -= 1;
  }
  if (index == 0 || text[index - 1] != '@') return null;
  final int start = index - 1;
  // `@` must open a word — otherwise `you@example.com` is a mention of `example`.
  if (start > 0 && !_space.hasMatch(text[start - 1])) return null;
  return MentionTrigger(start: start, query: text.substring(index, caret));
}

/// Case-insensitive match on either the handle or the pen name — people search by
/// both.
List<MentionCandidate> filterMentionCandidates(
  List<MentionCandidate> candidates,
  String query,
) {
  final String needle = query.trim().toLowerCase();
  if (needle.isEmpty) return List<MentionCandidate>.of(candidates);
  return candidates
      .where(
        (MentionCandidate c) =>
            c.username.toLowerCase().contains(needle) ||
            c.penName.toLowerCase().contains(needle),
      )
      .toList(growable: false);
}

/// The result of inserting a mention: the new text, and where the caret belongs.
class MentionInsertion {
  const MentionInsertion({required this.text, required this.caret});

  final String text;
  final int caret;
}

/// Replace the `@…` at [trigger] with `@handle`, and report where the caret goes.
///
/// The caret is left *past* a space, which is what closes the typeahead: parked at
/// the end of the handle it would still be inside the token and the sheet would
/// reopen on the person just chosen. When the writer is mentioning someone
/// mid-sentence the following space already exists, so the caret steps over it
/// rather than a second one being inserted.
MentionInsertion insertMention(
  String text,
  MentionTrigger trigger,
  MentionCandidate candidate,
) {
  final String before = text.substring(0, trigger.start);
  final String after = text.substring(trigger.start + 1 + trigger.query.length);
  final bool spaceFollows = after.isNotEmpty && _space.hasMatch(after[0]);
  final String token = '@${candidate.username}${spaceFollows ? '' : ' '}';
  return MentionInsertion(
    text: '$before$token$after',
    caret: before.length + token.length + (spaceFollows ? 1 : 0),
  );
}

/// A comment as the server will receive it.
class RawCommentBody {
  const RawCommentBody({required this.body, required this.mentions});

  final String body;
  final List<String> mentions;
}

/// Display text → the raw body the server stores, plus the ids it will notify.
///
/// Only handles in [selected] are translated. A handle the writer typed by hand and
/// never picked from the typeahead stays literal text and notifies nobody — which
/// is the honest outcome, because the composer never confirmed *who* it meant.
/// (`notifyComment` performs **no access check** on the ids it is handed, so
/// "whoever the writer confirmed from a list of story members" is the only safe
/// source of an id.)
///
/// The returned [RawCommentBody.mentions] is the client's own parse of its own
/// body. The server unions it with its regex over the same body, so the two agree
/// in the happy path and any drift can only make the server notify *more*, never
/// less.
RawCommentBody toRawCommentBody(String text, List<MentionCandidate> selected) {
  final Map<String, MentionCandidate> byHandle = <String, MentionCandidate>{
    for (final MentionCandidate c in selected) c.username.toLowerCase(): c,
  };
  final Set<String> mentions = <String>{};
  final String body = text.replaceAllMapped(_handleToken, (Match match) {
    final MentionCandidate? candidate = byHandle[match[1]!.toLowerCase()];
    if (candidate == null) return match[0]!;
    mentions.add(candidate.id);
    return '@${candidate.id}';
  });
  return RawCommentBody(body: body, mentions: mentions.toList(growable: false));
}

/// Drop candidates whose handle is no longer in the text.
///
/// Backing out of a mention — deleting it, or editing inside the handle — has to
/// *un-mention* the person, not leave a resolved id attached to prose that no
/// longer names them. Running this on every change is what makes the character
/// count and the ids sent describe the text as it actually stands.
List<MentionCandidate> pruneMentions(
  String text,
  List<MentionCandidate> selected,
) {
  final Set<String> present = _handleToken
      .allMatches(text)
      .map((Match m) => m[1]!.toLowerCase())
      .toSet();
  return selected
      .where((MentionCandidate c) => present.contains(c.username.toLowerCase()))
      .toList(growable: false);
}

/// What the writer is about to send, measured the way the server measures it.
///
/// `@MaxLength(MAX_COMMENT_BODY_LENGTH)` is applied server-side to the **raw**
/// string, where every mention is 37 characters. A composer that counted the
/// visible text would let a writer past a limit the server then rejects, with
/// nothing on screen to explain the gap.
int rawCommentBodyLength(String text, List<MentionCandidate> selected) =>
    toRawCommentBody(text, selected).body.length;

/// Whether the raw body — not the visible text — would be refused by the server.
bool exceedsCommentBodyLimit(String text, List<MentionCandidate> selected) =>
    rawCommentBodyLength(text, selected) > Limits.storyCommentBodyMax;

/// One run of a stored body: literal text, or a mention of [userId].
class BodySegment {
  const BodySegment.text(this.value) : userId = null;
  const BodySegment.mention(this.userId) : value = null;

  final String? value;
  final String? userId;

  bool get isMention => userId != null;
}

/// Segment a raw body for rendering.
///
/// Kept beside the compose half so both directions agree on what a mention *is* —
/// the render side is the reason the compose side is allowed to write ids at all.
List<BodySegment> segmentCommentBody(String body) {
  final List<BodySegment> segments = <BodySegment>[];
  int cursor = 0;
  for (final Match match in mentionUuidPattern.allMatches(body)) {
    if (match.start > cursor) {
      segments.add(BodySegment.text(body.substring(cursor, match.start)));
    }
    segments.add(BodySegment.mention(match[1]!.toLowerCase()));
    cursor = match.end;
  }
  if (cursor < body.length) {
    segments.add(BodySegment.text(body.substring(cursor)));
  }
  return segments;
}
