class ExpenseBar {
  int x;
  double amount;

  ExpenseBar({
    required this.x,
    required this.amount,
  });

  fromRow(Map<String, dynamic> row) {
    return ExpenseBar(
      x: row['x'],
      amount: row['amount'],
    );
  }
}
