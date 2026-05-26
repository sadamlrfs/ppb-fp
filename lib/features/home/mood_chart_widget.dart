import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../models/mood_model.dart';

class MoodChartWidget extends StatelessWidget {
  final List<MoodModel> moods;

  const MoodChartWidget({super.key, required this.moods});

  @override
  Widget build(BuildContext context) {
    if (moods.isEmpty) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        child: const Text('Belum ada data mood',
            style: TextStyle(color: Colors.grey)),
      );
    }

    final sorted = [...moods]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final spots = sorted.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.moodLevel.toDouble());
    }).toList();

    return SizedBox(
      height: 160,
      child: LineChart(
        LineChartData(
          minY: 1,
          maxY: 5,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 28,
                getTitlesWidget: (val, _) {
                  const emojis = ['😢', '😕', '😐', '😊', '😄'];
                  final idx = val.toInt() - 1;
                  if (idx < 0 || idx >= emojis.length) return const SizedBox();
                  return Text(emojis[idx], style: const TextStyle(fontSize: 12));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (val, _) {
                  final idx = val.toInt();
                  if (idx < 0 || idx >= sorted.length) return const SizedBox();
                  final date = sorted[idx].createdAt;
                  return Text('${date.day}/${date.month}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey));
                },
              ),
            ),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
