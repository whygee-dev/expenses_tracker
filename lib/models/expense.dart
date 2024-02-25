import '../powersync.dart';
import 'package:powersync/sqlite3.dart' as sqlite;

class Expense {
  final String id;
  final double amount;
  final String description;
  final String createdBy;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.createdBy,
    required this.createdAt,
  });

  factory Expense.fromRow(sqlite.Row row) {
    return Expense(
      id: row['id'],
      amount: row['amount'],
      description: row['description'],
      createdBy: row['createdBy'],
      createdAt: DateTime.parse(row['createdAt']),
    );
  }

  Future<void> delete() async {
    await db.execute('DELETE FROM "Expenses" WHERE id = ?', [id]);
  }

  Future<void> create() async {
    await db.execute(
      'INSERT INTO "Expenses" (id, amount, description, createdBy, createdAt) VALUES (?, ?, ?, ?, ?)',
      [
        id,
        amount,
        description,
        createdBy,
        createdAt.toIso8601String(),
      ],
    );
  }

  Future<void> update(
      {required double amount, required String description}) async {
    await db.execute(
      'UPDATE "Expenses" SET amount = ?, description = ? WHERE id = ?',
      [amount, description, id],
    );
  }
}
