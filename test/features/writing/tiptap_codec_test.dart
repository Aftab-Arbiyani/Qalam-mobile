import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/writing/domain/editor/editor_block.dart';
import 'package:qalam_mobile/features/writing/domain/editor/editor_document.dart';
import 'package:qalam_mobile/features/writing/domain/editor/marked_text.dart';
import 'package:qalam_mobile/features/writing/domain/editor/tiptap_codec.dart';

void main() {
  group('tiptap_codec round-trip', () {
    test('paragraph with bold/italic marks survives encode→decode', () {
      final EditorDocument doc = EditorDocument.of(<EditorBlock>[
        EditorBlock(
          id: 'b0',
          type: EditorBlockType.paragraph,
          text: MarkedText('hello brave world', const <MarkRange>[
            MarkRange(6, 11, TextMark.bold),
            MarkRange(12, 17, TextMark.italic),
          ]),
        ),
      ]);
      final EditorDocument back = decodeDocument(encodeDocument(doc));
      final EditorBlock b = back.blocks.single;
      expect(b.type, EditorBlockType.paragraph);
      expect(b.text.text, 'hello brave world');
      expect(b.text.activeMarks(6, 11), <TextMark>{TextMark.bold});
      expect(b.text.activeMarks(12, 17), <TextMark>{TextMark.italic});
    });

    test('headings map to level 2–4 and back', () {
      for (final EditorBlockType type in <EditorBlockType>[
        EditorBlockType.heading2,
        EditorBlockType.heading3,
        EditorBlockType.heading4,
      ]) {
        final EditorDocument doc = EditorDocument.of(<EditorBlock>[
          EditorBlock(id: 'b0', type: type, text: MarkedText.plain('Title')),
        ]);
        final EditorDocument back = decodeDocument(encodeDocument(doc));
        expect(back.blocks.single.type, type);
      }
    });

    test('ordered list items round-trip with start ordinal', () {
      final EditorDocument doc = EditorDocument.of(<EditorBlock>[
        EditorBlock(
          id: 'b0',
          type: EditorBlockType.orderedList,
          text: MarkedText.plain('one\ntwo\nthree'),
          listStart: 3,
        ),
      ]);
      final Map<String, dynamic> encoded = encodeDocument(doc);
      final EditorDocument back = decodeDocument(encoded);
      final EditorBlock b = back.blocks.single;
      expect(b.type, EditorBlockType.orderedList);
      expect(b.listStart, 3);
      expect(b.text.text, 'one\ntwo\nthree');
    });

    test('encoded doc is a valid TipTap doc node', () {
      final Map<String, dynamic> encoded = encodeDocument(
        EditorDocument.blank(),
      );
      expect(encoded['type'], 'doc');
      expect(encoded['content'], isA<List<dynamic>>());
    });

    test('only whitelisted marks are emitted', () {
      final Map<String, dynamic> encoded = encodeDocument(
        EditorDocument.of(<EditorBlock>[
          EditorBlock(
            id: 'b0',
            type: EditorBlockType.paragraph,
            text: MarkedText('x', const <MarkRange>[
              MarkRange(0, 1, TextMark.underline),
            ]),
          ),
        ]),
      );
      final Map<String, dynamic> para =
          (encoded['content'] as List<dynamic>).first as Map<String, dynamic>;
      final Map<String, dynamic> textNode =
          (para['content'] as List<dynamic>).first as Map<String, dynamic>;
      final List<dynamic> marks = textNode['marks'] as List<dynamic>;
      expect(marks, <Map<String, dynamic>>[
        <String, dynamic>{'type': 'underline'},
      ]);
    });
  });

  group('tiptap_codec decode tolerance', () {
    test('null / non-doc yields a blank document', () {
      expect(decodeDocument(null).blocks.length, 1);
      expect(decodeDocument(<String, dynamic>{}).blocks.length, 1);
    });

    test('unknown top-level nodes are skipped', () {
      final EditorDocument doc = decodeDocument(<String, dynamic>{
        'type': 'doc',
        'content': <dynamic>[
          <String, dynamic>{'type': 'horizontalRule'},
          <String, dynamic>{
            'type': 'paragraph',
            'content': <dynamic>[
              <String, dynamic>{'type': 'text', 'text': 'kept'},
            ],
          },
        ],
      });
      expect(doc.blocks.single.text.text, 'kept');
    });

    test('mentions and hashtags flatten to display text (lossy-but-safe)', () {
      final EditorDocument doc = decodeDocument(<String, dynamic>{
        'type': 'doc',
        'content': <dynamic>[
          <String, dynamic>{
            'type': 'paragraph',
            'content': <dynamic>[
              <String, dynamic>{'type': 'text', 'text': 'hi '},
              <String, dynamic>{
                'type': 'mention',
                'attrs': <String, dynamic>{'userId': 'u1', 'label': 'farheen'},
              },
              <String, dynamic>{'type': 'text', 'text': ' '},
              <String, dynamic>{
                'type': 'hashtag',
                'attrs': <String, dynamic>{'tag': 'poetry'},
              },
            ],
          },
        ],
      });
      expect(doc.blocks.single.text.text, 'hi @farheen #poetry');
    });

    test('hardBreak decodes to a newline within a paragraph', () {
      final EditorDocument doc = decodeDocument(<String, dynamic>{
        'type': 'doc',
        'content': <dynamic>[
          <String, dynamic>{
            'type': 'paragraph',
            'content': <dynamic>[
              <String, dynamic>{'type': 'text', 'text': 'a'},
              <String, dynamic>{'type': 'hardBreak'},
              <String, dynamic>{'type': 'text', 'text': 'b'},
            ],
          },
        ],
      });
      expect(doc.blocks.single.text.text, 'a\nb');
    });
  });
}
