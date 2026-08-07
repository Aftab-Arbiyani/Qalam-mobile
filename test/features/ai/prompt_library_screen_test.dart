/// Closes docs/48 §3.12's "the prompt library has no wire at all" gap: mobile's only
/// output was a clipboard write (`prompt_library_screen.dart:92,116`), a dead end when
/// the clipboard is denied or unavailable. **Use in assistant** hands a preset's
/// instruction straight back to the caller (the editor opens the Writing Assistant
/// pre-filled with it — see `editor_prompt_library_assistant_test.dart` for that hop),
/// so these tests assert the screen's half: the action exists only when there is
/// somewhere to send the instruction, and popping actually carries the text.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/ai/ai.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

import '../../support/harness.dart';

const String _draftId = 'loc-1';

/// Hosts [PromptLibraryScreen] behind a real push/pop so `Navigator.pop(text)`
/// (`prompt_library_screen.dart`'s `_useInAssistant`) has somewhere to land — a
/// screen popped straight off `MaterialApp.home` can't return a value to anyone.
class _Host extends StatefulWidget {
  const _Host({this.routeId});
  final String? routeId;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  String? _result;
  bool _returned = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ElevatedButton(
            onPressed: () async {
              final String? r = await Navigator.of(context).push<String>(
                MaterialPageRoute<String>(
                  builder: (_) => PromptLibraryScreen(routeId: widget.routeId),
                ),
              );
              setState(() {
                _result = r;
                _returned = true;
              });
            },
            child: const Text('Open library'),
          ),
          if (_returned) Text('RESULT:${_result ?? "null"}'),
        ],
      ),
    ),
  );
}

/// `buildTestContainer` does real async I/O (Hive `openBox`, connectivity init),
/// which deadlocks under `testWidgets`' fake-async zone unless run through
/// [WidgetTester.runAsync] (docs/40 §38, `harness.dart`).
Future<ProviderContainer> _container(WidgetTester tester) async {
  late final ProviderContainer c;
  await tester.runAsync(() async {
    c = await buildTestContainer();
  });
  return c;
}

Future<void> _pumpHost(
  WidgetTester tester,
  ProviderContainer container, {
  String? routeId,
}) async {
  // The full preset shelf (7 built-ins) plus history overflows the default test
  // window; a `ListView`'s sliver only builds children within the viewport +
  // cache extent, so anything past "Academic" would silently never exist in the
  // tree rather than just being scrolled off — tall enough here that it all does.
  tester.view.physicalSize = const Size(700, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildQalamTheme(brightness: Brightness.light),
        home: _Host(routeId: routeId),
      ),
    ),
  );
}

Future<void> _openLibrary(WidgetTester tester) async {
  await tester.tap(find.text('Open library'));
  await tester.pumpAndSettle();
}

void main() {
  group('Use in assistant is reachable only from a draft (docs/48 §3.12)', () {
    testWidgets('absent when the screen was opened without a routeId', (
      WidgetTester tester,
    ) async {
      final ProviderContainer c = await _container(tester);
      addTearDown(c.dispose);
      await _pumpHost(tester, c);
      await _openLibrary(tester);

      expect(find.byType(PromptLibraryScreen), findsOneWidget);
      expect(find.byTooltip('Use in assistant'), findsNothing);
      // Copy is unaffected — still the only, still-working way out.
      await tester.tap(find.text('General writing'));
      await tester.pump();
      expect(find.text('Prompt copied.'), findsOneWidget);
    });

    testWidgets('present on every built-in preset when a routeId is supplied', (
      WidgetTester tester,
    ) async {
      final ProviderContainer c = await _container(tester);
      addTearDown(c.dispose);
      await _pumpHost(tester, c, routeId: _draftId);
      await _openLibrary(tester);

      // 7 built-in presets, one "Use in assistant" action each.
      expect(find.byTooltip('Use in assistant'), findsNWidgets(7));
    });
  });

  group('tapping Use in assistant hands the instruction back (docs/48 §3.12)', () {
    testWidgets('pops the screen carrying the preset instruction', (
      WidgetTester tester,
    ) async {
      final ProviderContainer c = await _container(tester);
      addTearDown(c.dispose);
      await _pumpHost(tester, c, routeId: _draftId);
      await _openLibrary(tester);

      await tester.tap(find.byTooltip('Use in assistant').first);
      await tester.pumpAndSettle();

      // Back on the host, holding the "General writing" preset's instruction.
      expect(find.byType(PromptLibraryScreen), findsNothing);
      expect(
        find.text(
          'RESULT:Help me improve this passage while keeping my voice and '
          'meaning intact.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('also records the instruction to history', (
      WidgetTester tester,
    ) async {
      final ProviderContainer c = await _container(tester);
      addTearDown(c.dispose);
      await _pumpHost(tester, c, routeId: _draftId);
      await _openLibrary(tester);

      // `recordUse` is a real (unawaited) Hive write — `tapAndSettle` runs the tap
      // on the real event loop so that write actually lands before we assert on it
      // (harness.dart; a plain fake-async `tap`+`pumpAndSettle` cannot advance it).
      await tapAndSettle(tester, find.byTooltip('Use in assistant').first);

      expect(
        c.read(promptLibraryControllerProvider).history,
        contains(
          'Help me improve this passage while keeping my voice and '
          'meaning intact.',
        ),
      );
    });

    testWidgets('works from a history entry too', (WidgetTester tester) async {
      final ProviderContainer c = await _container(tester);
      addTearDown(c.dispose);
      await tester.runAsync(
        () => c
            .read(promptLibraryControllerProvider.notifier)
            .recordUse('Make this scarier'),
      );
      await _pumpHost(tester, c, routeId: _draftId);
      await _openLibrary(tester);

      expect(find.text('Make this scarier'), findsOneWidget);
      // Scoped to the history row specifically — built-in presets have their own
      // "Use in assistant" buttons earlier in the list, and `.first` would hit
      // one of those instead.
      final Finder historyTile = find.ancestor(
        of: find.text('Make this scarier'),
        matching: find.byType(ListTile),
      );
      await tester.tap(
        find.descendant(
          of: historyTile,
          matching: find.byTooltip('Use in assistant'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('RESULT:Make this scarier'), findsOneWidget);
    });
  });
}
