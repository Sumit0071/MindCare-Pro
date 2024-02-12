import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DayStatisticsPage extends StatelessWidget {
  final Map<String, double> data;
  final String selectedDate;

  const DayStatisticsPage(this.data, this.selectedDate);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD1A9FF),
        title: Text(selectedDate),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: RotatedBox(
            quarterTurns: 1,
            child: SizedBox(
              width: 0.5 * MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      gridData: FlGridData(show: false),
                      maxY: 10,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        leftTitles: SideTitles(showTitles: false),
                        rightTitles: SideTitles(showTitles: false),
                        topTitles: SideTitles(showTitles: false),
                        bottomTitles: SideTitles(showTitles: false),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: data.entries.map((entry) {
                        return BarChartGroupData(
                          x: data.keys.toList().indexOf(entry.key),
                          barRods: [
                            BarChartRodData(
                              y: entry.value,
                              colors: [_getColor(entry.key)],
                              width: 30,
                            ),
                          ],
                          showingTooltipIndicators: [0],
                        );
                      }).toList(),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Row(
                      children: data.keys.map((key) {
                        return Expanded(
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Text(
                              key,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getColor(String key) {
    List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];
    final index = data.keys.toList().indexOf(key);
    return colors[index % colors.length];
  }
}
