import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/writing/domain/editor/marked_text.dart';
import 'package:qalam_mobile/features/writing/presentation/editor/rich_text_controller.dart';

void main() {
  Future<BuildContext> pumpContext(WidgetTester tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext c) {
            ctx = c;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return ctx;
  }

  testWidgets('typing maps marks through the edit', (
    WidgetTester tester,
  ) async {
    final RichTextEditingController controller = RichTextEditingController(
      marked: MarkedText('bold text', const <MarkRange>[
        MarkRange(0, 4, TextMark.bold),
      ]),
    );
    addTearDown(controller.dispose);
    // Insert before the bold run — it shifts, nothing is swept in.
    controller.value = const TextEditingValue(
      text: 'X bold text',
      selection: TextSelection.collapsed(offset: 2),
    );
    expect(controller.marked.marks, <MarkRange>[
      const MarkRange(2, 6, TextMark.bold),
    ]);
  });

  testWidgets('keeps mark styling while the IME is composing', (
    WidgetTester tester,
  ) async {
    final BuildContext ctx = await pumpContext(tester);
    final RichTextEditingController controller = RichTextEditingController(
      marked: MarkedText('bold text', const <MarkRange>[
        MarkRange(0, 4, TextMark.bold),
      ]),
    );
    addTearDown(controller.dispose);
    // Compose over "d tex" — straddles the bold run boundary.
    controller.value = controller.value.copyWith(
      composing: const TextRange(start: 3, end: 8),
    );

    final TextSpan span = controller.buildTextSpan(
      context: ctx,
      style: const TextStyle(),
      withComposing: true,
    );
    final List<TextSpan> segments = span.children!.cast<TextSpan>();
    expect(segments.map((TextSpan s) => s.text), <String>[
      'bol', // bold, before composing
      'd', // bold + composing underline
      ' tex', // composing underline only
      't', // plain tail
    ]);
    expect(segments[0].style!.fontWeight, FontWeight.w700);
    expect(segments[0].style!.decoration, isNull);
    expect(segments[1].style!.fontWeight, FontWeight.w700);
    expect(segments[1].style!.decoration, TextDecoration.underline);
    expect(segments[2].style!.fontWeight, isNull);
    expect(segments[2].style!.decoration, TextDecoration.underline);
    expect(segments[3].style!.decoration, isNull);
  });

  testWidgets('composing underline combines with an underline mark', (
    WidgetTester tester,
  ) async {
    final BuildContext ctx = await pumpContext(tester);
    final RichTextEditingController controller = RichTextEditingController(
      marked: MarkedText('under', const <MarkRange>[
        MarkRange(0, 5, TextMark.underline),
      ]),
    );
    addTearDown(controller.dispose);
    controller.value = controller.value.copyWith(
      composing: const TextRange(start: 0, end: 5),
    );
    final TextSpan span = controller.buildTextSpan(
      context: ctx,
      style: const TextStyle(),
      withComposing: true,
    );
    final TextSpan only = span.children!.cast<TextSpan>().single;
    expect(only.style!.decoration!.contains(TextDecoration.underline), isTrue);
  });
}
