import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/gen_ui_response.dart';

class AdminChartWidget extends StatelessWidget {
  final ChartData? chartData;

  const AdminChartWidget({super.key, required this.chartData});

  static const List<Color> _palette = [
    Color(0xFF3F51B5), 
    Color(0xFF009688), 
    Color(0xFFFF9800), 
    Color(0xFFE91E63), 
    Color(0xFF9C27B0), 
    Color(0xFF2196F3), 
  ];

  @override
  Widget build(BuildContext context) {
    if (chartData == null || chartData!.values.isEmpty) {
      return const Text('Дані для побудови діаграми відсутні.');
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: Colors.indigo),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    chartData!.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: chartData!.chartType == 'pie'
                  ? _buildPieChart()
                  : _buildBarChart(),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final double maxValue = chartData!.values.reduce(max);
    // Розраховуємо коректний крок для вертикальної осі, щоб цифри не злипалися
    final double maxY = (maxValue * 1.25).ceilToDouble();
    final double interval = (maxY / 4).clamp(10, 500).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (val) => FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          // Ліва вісь: фіксований відступ 38 пікселів та крок
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              interval: interval,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10, color: Colors.blueGrey),
                  textAlign: TextAlign.right,
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < chartData!.labels.length) {
                  final text = chartData!.labels[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      text.length > 7 ? '${text.substring(0, 6)}..' : text,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: List.generate(chartData!.values.length, (i) {
          final barColor = _palette[i % _palette.length];
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: chartData!.values[i],
                color: barColor, // Кожен стовпчик має власний колір
                width: 22,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 36,
        sections: List.generate(chartData!.values.length, (i) {
          final color = _palette[i % _palette.length];
          return PieChartSectionData(
            color: color,
            value: chartData!.values[i],
            title: '${chartData!.values[i].toInt()}',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: List.generate(chartData!.labels.length, (i) {
        final color = _palette[i % _palette.length];
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(
              '${chartData!.labels[i]}: ${chartData!.values[i].toInt()}',
              style: const TextStyle(fontSize: 11, color: Colors.black87),
            ),
          ],
        );
      }),
    );
  }
}