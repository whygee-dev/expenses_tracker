import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/expense.dart';
import '../types.dart';
import '../utils.dart';

class ExpensesList extends StatelessWidget {
  final List<Expense> expenses;
  final Widget Function(BuildContext) Function(ExpenseAction,
      {Expense? expense}) dialogBuilder;
  const ExpensesList(
      {super.key, required this.expenses, required this.dialogBuilder});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        var expense = expenses[index];

        return Slidable(
          startActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {
                  showDialog(
                    context: context,
                    builder: dialogBuilder(
                      ExpenseAction.edit,
                      expense: expense,
                    ),
                  );
                },
                label: 'Edit',
                backgroundColor: Colors.blue,
                icon: Icons.edit,
              ),
            ],
          ),
          endActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
              SlidableAction(
                onPressed: (context) async {
                  await expense.delete();
                },
                label: 'Delete',
                backgroundColor: Colors.red,
                icon: Icons.delete,
              ),
            ],
          ),
          child: ListTile(
            title: Text(
              expense.description,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              formatYYYYMMDD(expense.createdAt),
            ),
            trailing: Text(
              "\$${removeDecimalZeroFormat(expense.amount)}",
            ),
            textColor: Colors.white,
          ),
        );
      },
    );
  }
}
