import 'package:expenses_tracker/powersync.dart';
import 'package:flutter/material.dart';

class WeekTotal extends StatelessWidget {
  const WeekTotal({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: db.watch(
        """
        SELECT sum(amount) as total
        FROM "Expenses"
        WHERE createdAt > (SELECT DATETIME('now', '-7 day'))
        """,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var total = snapshot.data?.first['total'] ?? 0.0;

          return Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Week Total: \$${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
        }

        return const CircularProgressIndicator();
      },
    );
  }
}
