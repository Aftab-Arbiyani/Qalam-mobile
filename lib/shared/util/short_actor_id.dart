/// The honest fallback for a person the app cannot name.
///
/// Since B3 (`platfrom/docs/45` §4) every id-bearing surface resolves a real
/// profile through `actorProfileProvider`, so this is no longer the default —
/// it is the floor. A deleted account, a failed lookup, or a first paint before
/// the profile arrives still has to render something, and a recognisable id
/// fragment beats both a blank row and a fabricated name.
library;

String shortActorId(String? id) {
  if (id == null || id.isEmpty) return 'someone';
  return id.length > 12
      ? '${id.substring(0, 4)}…${id.substring(id.length - 4)}'
      : id;
}
