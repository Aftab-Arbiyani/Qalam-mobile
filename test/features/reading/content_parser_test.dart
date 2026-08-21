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

  // ── parseContentWithAnchors (docs/48 §3.22a) ─────────────────────────────────
  //
  // Pins the server's `anchorText` coordinate space directly against the backend's
  // own worked example (`content-text.util.ts`'s file header, mirrored by
  // `content-text.divergence.spec.ts`): every `type: 'text'` leaf, concatenated
  // verbatim, with NO separator anywhere — not between text runs, not between
  // blocks.
  group('parseContentWithAnchors', () {
    test('two paragraphs concatenate with zero separator, not a space', () {
      final (
        PieceContent content,
        Map<BlockNode, BlockAnchor> anchors,
      ) = parseContentWithAnchors(<String, dynamic>{
        'type': 'doc',
        'content': <dynamic>[
          <String, dynamic>{
            'type': 'paragraph',
            'content': <dynamic>[
              <String, dynamic>{'type': 'text', 'text': 'first'},
            ],
          },
          <String, dynamic>{
            'type': 'paragraph',
            'content': <dynamic>[
              <String, dynamic>{'type': 'text', 'text': 'second'},
            ],
          },
        ],
      });

      final BlockAnchor first = anchors[content.blocks[0]]!;
      final BlockAnchor second = anchors[content.blocks[1]]!;
      expect((first.from, first.to, first.text), (0, 5, 'first'));
      // 5, not 6 — "firstsecond" (11 chars), not "first second" (12).
      expect((second.from, second.to, second.text), (5, 11, 'second'));
    });

    test('whitespace is preserved verbatim, never trimmed or collapsed', () {
      final (
        PieceContent content,
        Map<BlockNode, BlockAnchor> anchors,
      ) = parseContentWithAnchors(<String, dynamic>{
        'type': 'doc',
        'content': <dynamic>[
          <String, dynamic>{
            'type': 'paragraph',
            'content': <dynamic>[
              <String, dynamic>{'type': 'text', 'text': '  spaced  '},
            ],
          },
        ],
      });
      final BlockAnchor anchor = anchors[content.blocks.single]!;
      expect(anchor.text, '  spaced  ');
      expect(anchor.to - anchor.from, 10);
    });

    test('a non-text-typed node carrying a stray text key contributes zero', () {
      final (
        PieceContent content,
        Map<BlockNode, BlockAnchor> anchors,
      ) = parseContentWithAnchors(<String, dynamic>{
        'type': 'doc',
        'content': <dynamic>[
          <String, dynamic>{
            'type': 'image',
            'text': 'alt text nobody should count',
          },
          <String, dynamic>{
            'type': 'paragraph',
            'content': <dynamic>[
              <String, dynamic>{'type': 'text', 'text': 'real'},
            ],
          },
        ],
      });
      // The image contributes nothing, so the paragraph starts at 0, not past it.
      final BlockAnchor anchor = anchors[content.blocks[1]]!;
      expect(anchor.from, 0);
      expect(anchor.text, 'real');
    });

    test('an unknown block type with NESTED text still advances the offset '
        '(the bug an earlier draft of this had: skipping it undercounts every '
        'later block)', () {
      final (
        PieceContent content,
        Map<BlockNode, BlockAnchor> anchors,
      ) = parseContentWithAnchors(<String, dynamic>{
        'type': 'doc',
        'content': <dynamic>[
          <String, dynamic>{
            'type': 'callout',
            'content': <dynamic>[
              <String, dynamic>{
                'type': 'paragraph',
                'content': <dynamic>[
                  <String, dynamic>{'type': 'text', 'text': 'hidden'},
                ],
              },
            ],
          },
          <String, dynamic>{
            'type': 'paragraph',
            'content': <dynamic>[
              <String, dynamic>{'type': 'text', 'text': 'visible'},
            ],
          },
        ],
      });

      expect(content.blocks[0], isA<UnknownBlock>());
      // "hidden" (6 chars) counted even though mobile cannot render what was
      // inside the unknown node — matching the backend's type-agnostic walk.
      final BlockAnchor visible = anchors[content.blocks[1]]!;
      expect((visible.from, visible.to, visible.text), (6, 13, 'visible'));
    });

    test('an empty paragraph gets no anchor entry and consumes no offset', () {
      final (
        PieceContent content,
        Map<BlockNode, BlockAnchor> anchors,
      ) = parseContentWithAnchors(<String, dynamic>{
        'type': 'doc',
        'content': <dynamic>[
          <String, dynamic>{'type': 'paragraph', 'content': <dynamic>[]},
          <String, dynamic>{
            'type': 'paragraph',
            'content': <dynamic>[
              <String, dynamic>{'type': 'text', 'text': 'next'},
            ],
          },
        ],
      });
      expect(anchors.containsKey(content.blocks[0]), isFalse);
      final BlockAnchor next = anchors[content.blocks[1]]!;
      expect(next.from, 0);
    });

    test('mentions, hashtags, footnotes and hard breaks contribute zero', () {
      final (
        PieceContent content,
        Map<BlockNode, BlockAnchor> anchors,
      ) = parseContentWithAnchors(<String, dynamic>{
        'type': 'doc',
        'content': <dynamic>[
          <String, dynamic>{
            'type': 'paragraph',
            'content': <dynamic>[
              <String, dynamic>{'type': 'text', 'text': 'a'},
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
              <String, dynamic>{'type': 'text', 'text': 'b'},
            ],
          },
        ],
      });
      final BlockAnchor anchor = anchors[content.blocks.single]!;
      // Only the two literal text leaves count — "ab", not "a\n *@farheen#ghazalb".
      expect(anchor.text, 'ab');
      expect(anchor.to - anchor.from, 2);
    });

    test('produces the same tree shape as parsePieceContent', () {
      final Map<String, dynamic> doc = <String, dynamic>{
        'type': 'doc',
        'content': <dynamic>[
          <String, dynamic>{
            'type': 'heading',
            'attrs': <String, dynamic>{'level': 2},
            'content': <dynamic>[
              <String, dynamic>{'type': 'text', 'text': 'Title'},
            ],
          },
        ],
      };
      final PieceContent plain = parsePieceContent(doc);
      final (PieceContent anchored, _) = parseContentWithAnchors(doc);
      expect(anchored.blocks, hasLength(plain.blocks.length));
      expect(anchored.blocks.single, isA<Heading>());
      expect(
        (anchored.blocks.single as Heading).level,
        (plain.blocks.single as Heading).level,
      );
    });
  });
}
