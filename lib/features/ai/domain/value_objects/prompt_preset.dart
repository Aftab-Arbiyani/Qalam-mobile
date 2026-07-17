/// Prompt Library presets (AF2) — reusable, user-facing STARTERS for the assistant's
/// free-form "Ask AI". A preset carries a short, user-editable INSTRUCTION (the user's
/// message), never an AI system prompt — the system prompt is the server-side
/// `writing_assistant.freeform` template. This keeps the "never hardcode prompts in
/// UI" rule intact: presets are saved user messages, not model behaviour. Built-in
/// presets ship in code; custom presets, favourites, and history persist on-device.
library;

import '../../../../core/utils/typedefs.dart';

enum PromptPresetKind {
  generalWriting('General writing'),
  novel('Novel'),
  shortStory('Short story'),
  essay('Essay'),
  blog('Blog'),
  poetry('Poetry'),
  academic('Academic'),
  custom('Custom');

  const PromptPresetKind(this.label);
  final String label;

  static PromptPresetKind fromName(String? name) => PromptPresetKind.values.firstWhere(
        (PromptPresetKind k) => k.name == name,
        orElse: () => PromptPresetKind.custom,
      );
}

class PromptPreset {
  const PromptPreset({
    required this.id,
    required this.kind,
    required this.title,
    required this.description,
    required this.instruction,
    this.isBuiltIn = false,
    this.createdAt,
  });

  final String id;
  final PromptPresetKind kind;
  final String title;
  final String description;

  /// The starter instruction (a user message the assistant acts on). Editable.
  final String instruction;
  final bool isBuiltIn;
  final DateTime? createdAt;

  factory PromptPreset.custom({
    required String id,
    required String title,
    required String instruction,
    required DateTime createdAt,
  }) =>
      PromptPreset(
        id: id,
        kind: PromptPresetKind.custom,
        title: title.trim().isEmpty ? 'Custom prompt' : title.trim(),
        description: 'Your saved prompt',
        instruction: instruction.trim(),
        createdAt: createdAt,
      );

  Json toJson() => <String, dynamic>{
        'id': id,
        'kind': kind.name,
        'title': title,
        'description': description,
        'instruction': instruction,
        'isBuiltIn': isBuiltIn,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  factory PromptPreset.fromJson(Json json) => PromptPreset(
        id: json['id'] as String? ?? '',
        kind: PromptPresetKind.fromName(json['kind'] as String?),
        title: json['title'] as String? ?? 'Custom prompt',
        description: json['description'] as String? ?? '',
        instruction: json['instruction'] as String? ?? '',
        isBuiltIn: json['isBuiltIn'] as bool? ?? false,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      );
}

/// The built-in preset shelf (docs/AF2 prompt library). Instructions are neutral,
/// editable starting points — the writer tweaks before sending.
const List<PromptPreset> kBuiltInPromptPresets = <PromptPreset>[
  PromptPreset(
    id: 'preset.general_writing',
    kind: PromptPresetKind.generalWriting,
    title: 'General writing',
    description: 'Improve any passage while keeping your voice.',
    instruction: 'Help me improve this passage while keeping my voice and meaning intact.',
    isBuiltIn: true,
  ),
  PromptPreset(
    id: 'preset.novel',
    kind: PromptPresetKind.novel,
    title: 'Novel',
    description: 'Continue a scene with consistent POV and tense.',
    instruction:
        'Continue this scene, keeping the point of view and tense consistent, with vivid sensory detail.',
    isBuiltIn: true,
  ),
  PromptPreset(
    id: 'preset.short_story',
    kind: PromptPresetKind.shortStory,
    title: 'Short story',
    description: 'Tighten an opening so it hooks the reader.',
    instruction: 'Tighten this short story’s opening so it hooks the reader immediately.',
    isBuiltIn: true,
  ),
  PromptPreset(
    id: 'preset.essay',
    kind: PromptPresetKind.essay,
    title: 'Essay',
    description: 'Sharpen an argument and clarify reasoning.',
    instruction: 'Sharpen the argument in this passage and make the reasoning clearer.',
    isBuiltIn: true,
  ),
  PromptPreset(
    id: 'preset.blog',
    kind: PromptPresetKind.blog,
    title: 'Blog',
    description: 'Rewrite in a friendly, engaging blog voice.',
    instruction: 'Rewrite this in a friendly, engaging blog voice with a strong opening line.',
    isBuiltIn: true,
  ),
  PromptPreset(
    id: 'preset.poetry',
    kind: PromptPresetKind.poetry,
    title: 'Poetry',
    description: 'Suggest more evocative imagery.',
    instruction: 'Suggest more evocative imagery for these lines without changing their meaning.',
    isBuiltIn: true,
  ),
  PromptPreset(
    id: 'preset.academic',
    kind: PromptPresetKind.academic,
    title: 'Academic',
    description: 'Rewrite in a precise, formal register.',
    instruction: 'Rewrite this in a precise, formal academic register.',
    isBuiltIn: true,
  ),
];
