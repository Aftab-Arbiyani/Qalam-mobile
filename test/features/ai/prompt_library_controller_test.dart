import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/ai/ai.dart';

import '../../support/harness.dart';

void main() {
  test('favourites, custom presets, and history persist through the store', () async {
    final ProviderContainer c = await buildTestContainer();
    addTearDown(c.dispose);

    final PromptLibraryController notifier = c.read(promptLibraryControllerProvider.notifier);
    expect(c.read(promptLibraryControllerProvider).builtIn.length, 7);
    expect(c.read(promptLibraryControllerProvider).custom, isEmpty);

    await notifier.toggleFavorite('preset.novel');
    expect(c.read(promptLibraryControllerProvider).isFavorite('preset.novel'), isTrue);
    expect(c.read(promptLibraryControllerProvider).favorites.single.id, 'preset.novel');

    await notifier.addCustom(title: 'Punchy', instruction: 'Make it punchier');
    final PromptLibraryState afterAdd = c.read(promptLibraryControllerProvider);
    expect(afterAdd.custom.length, 1);
    expect(afterAdd.custom.single.instruction, 'Make it punchier');

    await notifier.recordUse('Tighten this');
    await notifier.recordUse('Tighten this'); // dedup
    await notifier.recordUse('Add tension');
    expect(c.read(promptLibraryControllerProvider).history, <String>['Add tension', 'Tighten this']);

    await notifier.clearHistory();
    expect(c.read(promptLibraryControllerProvider).history, isEmpty);
  });
}
