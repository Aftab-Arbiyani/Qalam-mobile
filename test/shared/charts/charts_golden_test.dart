import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/shared/charts/bar_chart.dart';
import 'package:qalam_mobile/shared/charts/chart_primitives.dart';
import 'package:qalam_mobile/shared/charts/line_chart.dart';
import 'package:qalam_mobile/shared/charts/pie_chart.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';
import 'package:qalam_mobile/shared/theme/q_tokens.dart';

/// Golden test (docs/40 §38.2) for the analytics chart primitives. Regenerate with
/// `--update-goldens`.
void main() {
  testWidgets('charts — line, bar, pie (light)', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildQalamTheme(brightness: Brightness.light),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              key: const Key('charts'),
              width: 360,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Builder(
                  builder: (BuildContext context) {
                    final QTokens tokens = QTokens.of(context);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        QLineChart(
                          semanticLabel: 'views',
                          height: 120,
                          series: <ChartSeries>[
                            ChartSeries(
                              label: 'Views',
                              color: tokens.colors.accent,
                              values: const <double>[3, 8, 6, 12, 15, 22, 30],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const QBarChart(
                          semanticLabel: 'reads',
                          height: 120,
                          bars: <ChartBar>[
                            ChartBar(label: 'Mon', value: 2),
                            ChartBar(label: 'Tue', value: 5),
                            ChartBar(label: 'Wed', value: 3),
                            ChartBar(label: 'Thu', value: 8),
                            ChartBar(label: 'Fri', value: 6),
                          ],
                        ),
                        const SizedBox(height: 16),
                        QPieChart(
                          semanticLabel: 'sources',
                          slices: <ChartSlice>[
                            ChartSlice(
                              label: 'In-app',
                              value: 60,
                              color: tokens.colors.accent,
                            ),
                            ChartSlice(
                              label: 'External',
                              value: 30,
                              color: tokens.colors.info,
                            ),
                            ChartSlice(
                              label: 'Copied',
                              value: 10,
                              color: tokens.colors.success,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('charts')),
      matchesGoldenFile('goldens/charts_light.png'),
    );
  });
}
