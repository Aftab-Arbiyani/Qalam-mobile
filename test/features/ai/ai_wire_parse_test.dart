import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/ai/domain/entities/ai_conversation.dart';
import 'package:qalam_mobile/features/ai/domain/entities/ai_usage.dart';
import 'package:qalam_mobile/features/ai/domain/value_objects/prompt_preset.dart';

void main() {
  group('AiUsageSummary.fromJson (token tracking)', () {
    test('maps windows, quota, and per-feature rows', () {
      final AiUsageSummary usage = AiUsageSummary.fromJson(<String, dynamic>{
        'daily': <String, dynamic>{
          'inputTokens': 100,
          'outputTokens': 50,
          'totalTokens': 150,
          'requests': 3,
          'estimatedCostUsd': 0.0012,
          'tokenLimit': 1000,
          'usedFraction': 0.15,
        },
        'monthly': <String, dynamic>{'totalTokens': 5000, 'requests': 40},
        'total': <String, dynamic>{'totalTokens': 20000, 'requests': 120},
        'byFeature': <dynamic>[
          <String, dynamic>{'feature': 'writing_assistant', 'totalTokens': 800, 'requests': 12},
        ],
      });
      expect(usage.daily.totalTokens, 150);
      expect(usage.daily.tokenLimit, 1000);
      expect(usage.daily.remaining, 850);
      expect(usage.daily.isUnlimited, isFalse);
      expect(usage.monthly.isUnlimited, isTrue); // no tokenLimit → unlimited
      expect(usage.byFeature.single.feature, 'writing_assistant');
      expect(usage.byFeature.single.totalTokens, 800);
    });
  });

  group('AiConversation parsing', () {
    test('detail parses summary fields + typed messages with usage', () {
      final AiConversationDetail detail = AiConversationDetail.fromJson(<String, dynamic>{
        'id': 'c1',
        'title': 'My chat',
        'feature': 'writing_assistant',
        'status': 'active',
        'messageCount': 2,
        'createdAt': '2026-01-01T00:00:00.000Z',
        'updatedAt': '2026-01-02T00:00:00.000Z',
        'messages': <dynamic>[
          <String, dynamic>{'id': 'm1', 'role': 'user', 'content': 'hi', 'createdAt': '2026-01-01T00:00:00.000Z'},
          <String, dynamic>{
            'id': 'm2',
            'role': 'assistant',
            'content': 'hello',
            'createdAt': '2026-01-01T00:00:01.000Z',
            'usage': <String, dynamic>{'inputTokens': 1, 'outputTokens': 2, 'totalTokens': 3},
          },
        ],
      });
      expect(detail.summary.displayTitle, 'My chat');
      expect(detail.summary.status, AiConversationStatus.active);
      expect(detail.messages.length, 2);
      expect(detail.messages[1].isAssistant, isTrue);
      expect(detail.messages[1].usage?.totalTokens, 3);
    });

    test('untitled conversation falls back to a stable placeholder', () {
      final AiConversationSummary c = AiConversationSummary.fromJson(<String, dynamic>{
        'id': 'c2',
        'feature': 'craft_coach',
        'status': 'archived',
      });
      expect(c.displayTitle, 'Untitled conversation');
      expect(c.status, AiConversationStatus.archived);
    });
  });

  group('PromptPreset persistence', () {
    test('custom preset round-trips through JSON', () {
      final PromptPreset preset = PromptPreset.custom(
        id: 'custom-1',
        title: 'My prompt',
        instruction: 'Make it shine',
        createdAt: DateTime(2026, 5, 4),
      );
      final PromptPreset restored = PromptPreset.fromJson(preset.toJson());
      expect(restored.id, 'custom-1');
      expect(restored.kind, PromptPresetKind.custom);
      expect(restored.instruction, 'Make it shine');
      expect(restored.isBuiltIn, isFalse);
    });

    test('ships the built-in preset shelf', () {
      expect(kBuiltInPromptPresets.length, 7);
      expect(kBuiltInPromptPresets.every((PromptPreset p) => p.isBuiltIn), isTrue);
    });
  });
}
