import 'package:expenses_tracker/widgets/graph.dart';
import 'package:expenses_tracker/widgets/status_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/expense.dart';
import '../powersync.dart';
import '../types.dart';
import '../widgets/expenses_list.dart';
import '../widgets/week_total.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final user = FirebaseAuth.instance.currentUser;
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();

  Widget Function(BuildContext) dialogBuilder(ExpenseAction action,
      {Expense? expense}) {
    if (action == ExpenseAction.edit) {
      if (expense == null) {
        throw ArgumentError('expense cannot be null');
      }

      descriptionController.text = expense.description;
      amountController.text = expense.amount.toString();
    }

    return (BuildContext context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: action == ExpenseAction.add
                ? const Text('Add Expense')
                : const Text('Edit Expense'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  controller: descriptionController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Amount'),
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (action == ExpenseAction.edit) {
                    if (expense == null) {
                      throw ArgumentError('expense cannot be null');
                    }

                    await expense.update(
                      amount: double.parse(amountController.text),
                      description: descriptionController.text,
                    );
                  }

                  if (action == ExpenseAction.add) {
                    await Expense(
                      id: const Uuid().v8(),
                      amount: double.parse(amountController.text),
                      description: descriptionController.text,
                      createdBy: user!.uid,
                      createdAt: DateTime.now(),
                    ).create();
                  }

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }

                  descriptionController.clear();
                  amountController.clear();
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: const StatusAppBar(title: 'Expenses Tracker'),
      body: Column(
        children: [
          const Expanded(
            flex: 3,
            child: WeekTotal(),
          ),
          Expanded(
            flex: 9,
            child: Graph(),
          ),
          Expanded(flex: 1, child: Container()),
          Expanded(
            flex: 24,
            child: StreamBuilder(
              stream:
                  db.watch('SELECT * FROM "Expenses" ORDER BY createdAt DESC'),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var expenses =
                      snapshot.data?.map((e) => Expense.fromRow(e)).toList() ??
                          [];

                  return ExpensesList(
                    expenses: expenses,
                    dialogBuilder: dialogBuilder,
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context, builder: dialogBuilder(ExpenseAction.add));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
