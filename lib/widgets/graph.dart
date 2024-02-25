import 'package:expenses_tracker/models/expense_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../powersync.dart';

class Graph extends StatefulWidget {
  Graph({super.key});

  @override
  State<Graph> createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: db.watch(
        """
            SELECT strftime('%w', createdAt) as day, sum(amount) as amount
            FROM "Expenses"
            WHERE createdAt > (SELECT DATETIME('now', '-7 day'))
            GROUP BY day
          """,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var data =
              snapshot.data?.map((e) => e as Map<String, dynamic>).toList();

          var bars = data != null
              ? List.generate(
                  7,
                  (i) {
                    var amountIndex = data.indexWhere(
                      (element) => element['day'] == i.toString(),
                    );
                    var amount =
                        amountIndex == -1 ? 0.0 : data[amountIndex]['amount'];

                    return ExpenseBar(x: i, amount: amount);
                  },
                )
              : [];

          var maxY = bars.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

          return BarChart(
            BarChartData(
              maxY: maxY,
              minY: 0,
              titlesData: FlTitlesData(
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text(
                      [
                        'Sun',
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat'
                      ][value.toInt()],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              gridData: const FlGridData(
                show: false,
              ),
              borderData: FlBorderData(
                show: false,
              ),
              barGroups: bars
                  .map(
                    (bar) => BarChartGroupData(
                      x: bar.x,
                      barRods: [
                        BarChartRodData(
                          toY: bar.amount,
                          width: 22,
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY,
                            color: Colors.grey[900],
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
