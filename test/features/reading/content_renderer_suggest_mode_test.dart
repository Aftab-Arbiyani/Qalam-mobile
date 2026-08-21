import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/reading/domain/content_parser.dart';
import 'package:qalam_mobile/features/reading/domain/entities/content_node.dart';
import 'package:qalam_mobile/features/reading/presentation/widgets/content_renderer.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

/// The "propose an edit" tap-target path (docs/48 §3.22a). `blockAnchors` +
/// `onBlockTap` are opt-in — the golden test (`content_renderer_golden_test.dart`)
/// pins the null-params path unchanged; this file covers the non-null one.
Widget _host(Widget child) => MaterialApp(
  theme: buildQalamTheme(brightness: Brightness.light),
  home: Scaffold(body: child),
);

void main() {
  final Map<String, dynamic> doc = <String, dynamic>{
    'type': 'doc',
    'content': <dynamic>[
      <String, dynamic>{
        'type': 'paragraph',
        'content': <dynamic>[
          <String, dynamic>{'type': 'text', 'text': 'first'},
        ],
      },
      <String, dynamic>{'type': 'paragraph', 'content': <dynamic>[]},
      <String, dynamic>{
        'type': 'paragraph',
        'content': <dynamic>[
          <String, dynamic>{'type': 'text', 'text': 'second'},
        ],
      },
    ],
  };

  testWidgets('tapping a paragraph fires onBlockTap with its exact anchor', (
    WidgetTester tester,
  ) async {
    final (PieceContent content, Map<BlockNode, BlockAnchor> anchors) =
        parseContentWithAnchors(doc);
    final List<(BlockNode, BlockAnchor)> taps = <(BlockNode, BlockAnchor)>[];

    await tester.pumpWidget(
      _host(
        ContentRenderer(
          content: content,
          baseFontSize: 16,
          lineHeight: 1.5,
          direction: TextDirectionKind.ltr,
          blockAnchors: anchors,
          onBlockTap: (BlockNode block, BlockAnchor anchor) =>
              taps.add((block, anchor)),
        ),
      ),
    );

    await tester.tap(find.text('second'));
    await tester.pump();

    expect(taps, hasLength(1));
    final BlockAnchor tapped = taps.single.$2;
    expect((tapped.from, tapped.to, tapped.text), (5, 11, 'second'));
  });

  testWidgets('an empty paragraph has no tap target', (
    WidgetTester tester,
  ) async {
    final (PieceContent content, Map<BlockNode, BlockAnchor> anchors) =
        parseContentWithAnchors(doc);
    int taps = 0;

    await tester.pumpWidget(
      _host(
        ContentRenderer(
          content: content,
          baseFontSize: 16,
          lineHeight: 1.5,
          direction: TextDirectionKind.ltr,
          blockAnchors: anchors,
          onBlockTap: (_, _) => taps++,
        ),
      ),
    );

    // The middle block is the empty paragraph — no InkWell wraps it, so there is
    // nothing there to tap. Confirm exactly two tappable blocks exist (first and
    // second), not three.
    expect(find.byType(InkWell), findsNWidgets(2));
    expect(taps, 0);
  });

  testWidgets('both null renders with no tap targets at all', (
    WidgetTester tester,
  ) async {
    final PieceContent content = parsePieceContent(doc);

    await tester.pumpWidget(
      _host(
        ContentRenderer(
          content: content,
          baseFontSize: 16,
          lineHeight: 1.5,
          direction: TextDirectionKind.ltr,
        ),
      ),
    );

    expect(find.byType(InkWell), findsNothing);
    expect(find.text('first'), findsOneWidget);
    expect(find.text('second'), findsOneWidget);
  });
}
