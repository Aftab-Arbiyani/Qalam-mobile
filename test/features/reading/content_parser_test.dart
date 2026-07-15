import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/reading/domain/content_parser.dart';
import 'package:qalam_mobile/features/reading/domain/entities/content_node.dart';

void main() {
  group('parsePieceContent', () {
    test('null / non-doc yields empty content', () {
      expect(parsePieceContent(null).blocks, isEmpty);
      expect(parsePieceContent(<String, dynamic>{}).blocks, isEmpty);
      expect(
        parsePieceContent(<String, dynamic>{'content': 'nope'}).blocks,
        isEmpty,
      );
    });

    test('parses a paragraph with marked text runs', () {
      final PieceContent content = parsePieceContent(<String, dynamic>{
        'type': 'doc',
        'content': <dynamic>[
          <String, dynamic>{
            'type': 'paragraph',
            'content': <dynamic>[
              <String, dynamic>{'type': 'text', 'text': 'Hello '},
              <String, dynamic>{
                'type': 'text',
                'text': 'bold',
                'marks': <dynamic>[
                  <String, dynamic>{'type': 'bold'},
                  <String, dynamic>{'type': 'italic'},
                ],
              },
            ],
          },
        ],
      });

      expect(content.blocks, hasLength(1));
      final Paragraph para = content.blocks.first as Paragraph;
      expect(para.spans, hasLength(2));
      final TextRun bold = para.spans[1] as TextRun;
      expect(bold.text, 'bold');
      expect(
        bold.marks,
        containsAll(<TextMark>[TextMark.bold, TextMark.italic]),
      );
    });

    test('clamps heading level to 2–4', () {
      final PieceContent content = parsePieceContent(<String, dynamic>{
        'type': 'doc',
        'content': <dynamic>[
          <String, dynamic>{
            'type': 'heading',
            'attrs': <String, dynamic>{'level': 1},
            'content': <dynamic>[
              <String, dynamic>{'type': 'text', 'text': 'H'},
            ],
          },
          <String, dynamic>{
            'type': 'heading',
            'attrs': <String, dynamic>{'level': 9},
            'content': <dynamic>[
              <String, dynamic>{'type': 'text', 'text': 'H'},
            ],
          },
        ],
      });
      expect((content.blocks[0] as Heading).level, 2);
      expect((content.blocks[1] as Heading).level, 4);
    });

    test('parses ordered and bullet lists with items', () {
      final PieceContent content = parsePieceContent(<String, dynamic>{
        'type': 'doc',
        'content': <dynamic>[
          <String, dynamic>{
            'type': 'orderedList',
            'attrs': <String, dynamic>{'start': 3},
            'content': <dynamic>[
              <String, dynamic>{
                'type': 'listItem',
                'content': <dynamic>[
                  <String, dynamic>{
                    'type': 'paragraph',
                    'content': <dynamic>[
                      <String, dynamic>{'type': 'text', 'text': 'one'},
                    ],
                  },
                ],
              },
            ],
          },
        ],
      });
      final ListBlock list = content.blocks.first as ListBlock;
      expect(list.ordered, isTrue);
      expect(list.start, 3);
      expect(list.items, hasLength(1));
      expect(list.items.first.children.first, isA<Paragraph>());
    });

    test('parses footnote, mention, hashtag, hardBreak inlines', () {
      final PieceContent content = parsePieceContent(<String, dynamic>{
        'type': 'doc',
        'content': <dynamic>[
          <String, dynamic>{
            'type': 'paragraph',
            'content': <dynamic>[
              <String, dynamic>{'type': 'hardBreak'},
              <String, dynamic>{
                'type': 'footnote',
                'attrs': <String, dynamic>{'id': 'f1'},
              },
              <String, dynamic>{
                'type': 'mention',
                'attrs': <String, dynamic>{'userId': 'u1', 'label': 'farheen'},
              },
              <String, dynamic>{
                'type': 'hashtag',
                'attrs': <String, dynamic>{'tag': 'ghazal'},
              },
            ],
          },
        ],
      });
      final Paragraph para = content.blocks.first as Paragraph;
      expect(para.spans[0], isA<LineBreak>());
      expect((para.spans[1] as FootnoteRef).id, 'f1');
      expect((para.spans[2] as Mention).label, 'farheen');
      expect((para.spans[3] as Hashtag).tag, 'ghazal');
    });

    test('unknown node/mark types degrade gracefully', () {
      final PieceContent content = parsePieceContent(<String, dynamic>{
        'type': 'doc',
        'content': <dynamic>[
          <String, dynamic>{
            'type': 'image',
            'attrs': <String, dynamic>{'src': 'x'},
          },
          <String, dynamic>{
            'type': 'paragraph',
            'content': <dynamic>[
              <String, dynamic>{
                'type': 'text',
                'text': 'link text',
                'marks': <dynamic>[
                  <String, dynamic>{
                    'type': 'link',
                    'attrs': <String, dynamic>{'href': 'x'},
                  },
                ],
              },
              <String, dynamic>{'type': 'emoji'},
            ],
          },
        ],
      });
      expect(content.blocks[0], isA<UnknownBlock>());
      expect((content.blocks[0] as UnknownBlock).type, 'image');
      final Paragraph para = content.blocks[1] as Paragraph;
      // Link mark is not whitelisted → dropped; text still renders.
      final TextRun run = para.spans[0] as TextRun;
      expect(run.marks, isEmpty);
      // Unknown inline node preserved as UnknownInline.
      expect(para.spans[1], isA<UnknownInline>());
    });

    test('empty text runs are skipped', () {
      final PieceContent content = parsePieceContent(<String, dynamic>{
        'type': 'doc',
        'content': <dynamic>[
          <String, dynamic>{
            'type': 'paragraph',
            'content': <dynamic>[
              <String, dynamic>{'type': 'text', 'text': ''},
              <String, dynamic>{'type': 'text', 'text': 'kept'},
            ],
          },
        ],
      });
      final Paragraph para = content.blocks.first as Paragraph;
      expect(para.spans, hasLength(1));
      expect((para.spans.first as TextRun).text, 'kept');
    });
  });
}
