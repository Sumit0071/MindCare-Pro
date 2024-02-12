// graph_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:code_redex_sih_2023/pages/graph_generator.dart';

class GraphPage extends StatelessWidget {
  final List<String> labels;
  final List<double> values;
  final String sessionId;
  GraphPage(GraphData graphData,
      {required List<double> values,
      required List<String> labels,
      required this.sessionId})
      : labels = graphData.labels,
        values = graphData.values;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Mental Health Analysis"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            groupsSpace: 12,
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: SideTitles(showTitles: false),
            ),
            barGroups: labels
                .asMap()
                .entries
                .map(
                  (entry) => BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        y: values[entry.key],
                        colors: [Colors.blue],
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
