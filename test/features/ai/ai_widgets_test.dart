import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/ai/domain/value_objects/coach_report.dart';
import 'package:qalam_mobile/features/ai/presentation/widgets/ai_markdown.dart';
import 'package:qalam_mobile/features/ai/presentation/widgets/coach_report_view.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

Widget _host(Widget child) => MaterialApp(
      theme: buildQalamTheme(brightness: Brightness.light),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  testWidgets('CoachReportView renders score, summary, and list items', (WidgetTester tester) async {
    const CoachReport report = CoachReport(
      score: 82,
      summary: 'Strong, confident voice.',
      strengths: <String>['Vivid imagery'],
      weaknesses: <String>['Slow opening'],
      suggestions: <String>['Cut the first sentence'],
      recommendations: <String>['Read it aloud'],
      sections: <CoachSection>[CoachSection(title: 'Voice', detail: 'Consistent.')],
    );

    await tester.pumpWidget(_host(const CoachReportView(report: report)));

    expect(find.text('82'), findsOneWidget);
    expect(find.text('Strong, confident voice.'), findsOneWidget);
    expect(find.text('Vivid imagery'), findsOneWidget);
    expect(find.text('Read it aloud'), findsOneWidget);
    expect(find.text('Voice'), findsOneWidget);
  });

  testWidgets('AiMarkdown renders a fenced code block with a copy affordance',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(const AiMarkdown('```dart\nvoid main() {}\n```')));
    expect(find.byIcon(Icons.copy), findsOneWidget);
    expect(find.text('dart'), findsOneWidget);
  });
}
