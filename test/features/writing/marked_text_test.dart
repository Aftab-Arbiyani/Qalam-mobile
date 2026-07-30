import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/writing/domain/editor/marked_text.dart';

void main() {
  group('MarkedText.toggleMark', () {
    test('adds a mark across a range', () {
      final MarkedText t = MarkedText.plain(
        'hello world',
      ).toggleMark(TextMark.bold, 0, 5);
      expect(t.activeMarks(0, 5), <TextMark>{TextMark.bold});
      expect(t.activeMarks(6, 11), isEmpty);
    });

    test('removes a mark when the whole range already has it', () {
      final MarkedText once = MarkedText.plain(
        'abc',
      ).toggleMark(TextMark.italic, 0, 3);
      final MarkedText twice = once.toggleMark(TextMark.italic, 0, 3);
      expect(twice.marks, isEmpty);
    });

    test('a collapsed selection is a no-op', () {
      final MarkedText t = MarkedText.plain(
        'abc',
      ).toggleMark(TextMark.bold, 1, 1);
      expect(t.marks, isEmpty);
    });

    test('normalizes overlapping ranges of the same mark', () {
      final MarkedText t = MarkedText('abcdef', const <MarkRange>[
        MarkRange(0, 3, TextMark.bold),
        MarkRange(2, 5, TextMark.bold),
      ]);
      expect(t.marks.length, 1);
      expect(t.marks.first, const MarkRange(0, 5, TextMark.bold));
    });
  });

  group('MarkedText.replace (edit mapping)', () {
    test('insertion before a marked run shifts it right', () {
      final MarkedText t = MarkedText('world', const <MarkRange>[
        MarkRange(0, 5, TextMark.bold),
      ]).replace(0, 0, 'hello ');
      expect(t.text, 'hello world');
      expect(t.activeMarks(6, 11), <TextMark>{TextMark.bold});
      expect(t.activeMarks(0, 5), isEmpty);
    });

    test('typing inside a marked run keeps the run marked', () {
      final MarkedText t = MarkedText('abcd', const <MarkRange>[
        MarkRange(0, 4, TextMark.bold),
      ]).replace(2, 0, 'XY');
      expect(t.text, 'abXYcd');
      expect(t.activeMarks(0, 6), <TextMark>{TextMark.bold});
    });

    test('deleting marked characters clips the range', () {
      final MarkedText t = MarkedText('abcdef', const <MarkRange>[
        MarkRange(0, 6, TextMark.underline),
      ]).replace(2, 2, '');
      expect(t.text, 'abef');
      expect(t.activeMarks(0, 4), <TextMark>{TextMark.underline});
    });
  });

  group('MarkedText split/concat', () {
    test('splitAt partitions text and marks', () {
      final (MarkedText a, MarkedText b) = MarkedText(
        'bolditalic',
        const <MarkRange>[
          MarkRange(0, 4, TextMark.bold),
          MarkRange(4, 10, TextMark.italic),
        ],
      ).splitAt(4);
      expect(a.text, 'bold');
      expect(a.activeMarks(0, 4), <TextMark>{TextMark.bold});
      expect(b.text, 'italic');
      expect(b.activeMarks(0, 6), <TextMark>{TextMark.italic});
    });

    test('concat offsets the second run marks', () {
      final MarkedText joined = MarkedText.plain('foo').concat(
        MarkedText('bar', const <MarkRange>[MarkRange(0, 3, TextMark.bold)]),
      );
      expect(joined.text, 'foobar');
      expect(joined.activeMarks(3, 6), <TextMark>{TextMark.bold});
    });
  });

  group('MarkedText.runs', () {
    test('coalesces consecutive equal mark sets', () {
      final List<StyledRun> runs = MarkedText('abcdef', const <MarkRange>[
        MarkRange(2, 4, TextMark.bold),
      ]).runs();
      expect(runs.map((StyledRun r) => r.text).toList(), <String>[
        'ab',
        'cd',
        'ef',
      ]);
      expect(runs[1].marks, <TextMark>{TextMark.bold});
    });
  });
}
