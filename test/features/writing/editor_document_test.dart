import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/writing/domain/editor/editor_block.dart';
import 'package:qalam_mobile/features/writing/domain/editor/editor_document.dart';
import 'package:qalam_mobile/features/writing/domain/editor/marked_text.dart';

void main() {
  group('EditorDocument', () {
    test('blank has one empty paragraph', () {
      final EditorDocument doc = EditorDocument.blank();
      expect(doc.blocks.length, 1);
      expect(doc.blocks.single.type, EditorBlockType.paragraph);
      expect(doc.isEmpty, isTrue);
    });

    test('splitBlock partitions text and yields a new focusable block', () {
      final EditorDocument doc = EditorDocument.of(<EditorBlock>[
        EditorBlock(
          id: 'b0',
          type: EditorBlockType.paragraph,
          text: MarkedText.plain('hello world'),
        ),
      ]);
      final result = doc.splitBlock('b0', 5);
      expect(result.document.blocks.length, 2);
      expect(result.document.blocks[0].text.text, 'hello');
      expect(result.document.blocks[1].text.text, ' world');
      expect(result.newBlockId, isNot('b0'));
      expect(result.document.indexOfId(result.newBlockId), 1);
    });

    test('splitting a list block keeps the list type', () {
      final EditorDocument doc = EditorDocument.of(<EditorBlock>[
        EditorBlock(
          id: 'b0',
          type: EditorBlockType.bulletList,
          text: MarkedText.plain('item'),
        ),
      ]);
      final result = doc.splitBlock('b0', 2);
      expect(result.document.blocks[1].type, EditorBlockType.bulletList);
    });

    test('mergeIntoPrevious joins and reports the caret', () {
      final EditorDocument doc = EditorDocument.of(<EditorBlock>[
        EditorBlock(
          id: 'b0',
          type: EditorBlockType.paragraph,
          text: MarkedText.plain('hello'),
        ),
        EditorBlock(
          id: 'b1',
          type: EditorBlockType.paragraph,
          text: MarkedText.plain(' world'),
        ),
      ]);
      final merged = doc.mergeIntoPrevious('b1')!;
      expect(merged.document.blocks.length, 1);
      expect(merged.document.blocks.single.text.text, 'hello world');
      expect(merged.focusId, 'b0');
      expect(merged.caret, 5);
    });

    test('mergeIntoPrevious on the first block is a no-op (null)', () {
      final EditorDocument doc = EditorDocument.blank();
      expect(doc.mergeIntoPrevious(doc.blocks.first.id), isNull);
    });

    test('removeBlock keeps at least one block', () {
      final EditorDocument doc = EditorDocument.blank();
      final EditorDocument after = doc.removeBlock(doc.blocks.first.id);
      expect(after.blocks.length, 1);
    });

    test('wordCount counts across blocks', () {
      final EditorDocument doc = EditorDocument.of(<EditorBlock>[
        EditorBlock(
          id: 'b0',
          type: EditorBlockType.heading2,
          text: MarkedText.plain('The Title'),
        ),
        EditorBlock(
          id: 'b1',
          type: EditorBlockType.paragraph,
          text: MarkedText.plain('one two three'),
        ),
      ]);
      expect(doc.wordCount, 5);
      expect(doc.hasContent, isTrue);
    });

    test('new block ids do not collide with decoded ids', () {
      final EditorDocument doc = EditorDocument.of(<EditorBlock>[
        EditorBlock(
          id: 'b0',
          type: EditorBlockType.paragraph,
          text: MarkedText.plain('a'),
        ),
        EditorBlock(
          id: 'b5',
          type: EditorBlockType.paragraph,
          text: MarkedText.plain('b'),
        ),
      ]);
      final result = doc.insertParagraphAfter('b5');
      expect(result.document.indexOfId(result.newBlockId), 2);
      expect(result.newBlockId, isNot('b0'));
      expect(result.newBlockId, isNot('b5'));
    });
  });
}
