import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../application/reports_providers.dart';

class CashFlowChart extends StatelessWidget {
  const CashFlowChart({super.key, required this.points});

  final List<CashFlowPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();
    final maxAbs = points
        .map((p) => p.net.abs())
        .fold<double>(1, (max, value) => value > max ? value : max);

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: -maxAbs * 1.2,
          maxY: maxAbs * 1.2,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(points[index].label,
                        style: Theme.of(context).textTheme.bodySmall),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: points
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.net))
                  .toList(),
              isCurved: true,
              color: const Color(0xFF2E7D32),
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
