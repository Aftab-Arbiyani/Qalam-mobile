/// B5 (`platfrom/docs/45` §4.10) — the account's own "turn AI off" switch.
///
/// Optimistic like the notification toggles (the switch moves under the thumb), then
/// reconciled with the server's authoritative response, or rolled back on failure.
///
/// **The invalidation is the point, not housekeeping.** Turning the switch off changes
/// what the SERVER does: AI requests answer `AI_DISABLED_BY_USER` and `GET /ai/features`
/// starts reporting every feature off. Every AI affordance on this client gates on
/// `aiFeaturesProvider`, so without invalidating it the writer would keep an editor
/// toolbar button, an overflow menu and a discovery tab that the server now refuses —
/// exactly the stranded entry points §4.10 forbids.
///
/// **Not merged with the `ai_personalization` consent**, which is a different question
/// ("may my work train the models") behind a different endpoint (`PUT /privacy/consent`)
/// and has no client surface on either platform yet.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../ai/presentation/providers/ai_providers.dart';
import '../../domain/entities/user_settings.dart';
import '../providers/settings_providers.dart';

part 'ai_preference_controller.g.dart';

@riverpod
class AiPreferenceController extends _$AiPreferenceController {
  @override
  Future<UserSettings> build() async {
    final result = await ref.read(userSettingsRepositoryProvider).get();
    return result.fold(
      (UserSettings settings) => settings,
      (Object failure) => throw failure,
    );
  }

  /// Flip the switch. Returns `true` when the server accepted it, so the screen can
  /// tell the writer plainly when it did not — a silent failure here would leave them
  /// believing AI was off while every AI request still succeeded.
  Future<bool> setEnabled(bool value) async {
    final UserSettings? current = state.asData?.value;
    if (current == null) return false;

    state = AsyncData<UserSettings>(current.copyWith(aiEnabled: value));

    final result = await ref
        .read(userSettingsRepositoryProvider)
        .setAiEnabled(value);

    return result.fold(
      (UserSettings updated) {
        state = AsyncData<UserSettings>(updated);
        // Re-read the gate every AI surface consults — see the note above.
        ref.invalidate(aiFeaturesProvider);
        return true;
      },
      (Object _) {
        state = AsyncData<UserSettings>(current); // rollback
        return false;
      },
    );
  }
}
