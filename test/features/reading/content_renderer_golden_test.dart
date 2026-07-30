import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/reading/domain/entities/content_node.dart';
import 'package:qalam_mobile/features/reading/presentation/widgets/content_renderer.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

/// Golden test (docs/40 §38.2, §41 §35) — the reading renderer in both directions.
/// The RTL golden is a build-blocker for Nastaliq/Urdu layout regressions. Uses a
/// fixed test font; regenerate with `--update-goldens`.
PieceContent _sample() => const PieceContent(<BlockNode>[
  Heading(level: 2, spans: <InlineNode>[TextRun('A Heading')]),
  Paragraph(<InlineNode>[
    TextRun('Plain '),
    TextRun('bold', marks: <TextMark>{TextMark.bold}),
    TextRun(' and '),
    TextRun('italic', marks: <TextMark>{TextMark.italic}),
    TextRun('.'),
  ]),
  Blockquote(<BlockNode>[
    Paragraph(<InlineNode>[TextRun('A quiet, considered line.')]),
  ]),
  ListBlock(
    ordered: false,
    items: <ListItemBlock>[
      ListItemBlock(<BlockNode>[
        Paragraph(<InlineNode>[TextRun('first')]),
      ]),
      ListItemBlock(<BlockNode>[
        Paragraph(<InlineNode>[TextRun('second')]),
      ]),
    ],
  ),
]);

Widget _host(Widget child) => MaterialApp(
  theme: buildQalamTheme(brightness: Brightness.light),
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: 360,
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ),
  ),
);

void main() {
  testWidgets('content renderer — LTR light', (WidgetTester tester) async {
    await tester.pumpWidget(
      _host(
        ContentRenderer(
          content: _sample(),
          baseFontSize: 18,
          lineHeight: 1.7,
          direction: TextDirectionKind.ltr,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(ContentRenderer),
      matchesGoldenFile('goldens/content_renderer_ltr_light.png'),
    );
  });

  testWidgets('content renderer — RTL light (Nastaliq layout)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        ContentRenderer(
          content: _sample(),
          baseFontSize: 22,
          lineHeight: 2.1,
          direction: TextDirectionKind.rtl,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(ContentRenderer),
      matchesGoldenFile('goldens/content_renderer_rtl_light.png'),
    );
  });
}
