import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SummaryPieChart extends StatelessWidget {
  final Map<String, double> data;

  const SummaryPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    double total = data.values.fold(0, (a, b) => a + b);

    return Column(
      children: [
        Text(
          'Total Pengeluaran Bulan ini',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          ).format(total).toString(),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections:
                  data.entries.map((entry) {
                    final value = entry.value;
                    final percentage = (value / total) * 100;

                    return PieChartSectionData(
                      value: value,
                      title: "${entry.key}\n${percentage.toStringAsFixed(1)}%",
                      radius: 60,
                      color: _getColorFromKey(entry.key),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Color _getColorFromKey(String key) {
    final hash = key.hashCode;
    final r = (hash & 0xFF0000) >> 16;
    final g = (hash & 0x00FF00) >> 8;
    final b = (hash & 0x0000FF);
    return Color.fromARGB(255, r, g, b);
  }
}
