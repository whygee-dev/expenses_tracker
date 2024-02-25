import 'package:powersync/powersync.dart';

const schema = Schema([
  Table('Expenses', [
    Column.text('description'),
    Column.real('amount'),
    Column.text('currency'),
    Column.text('createdBy'),
    Column.text('createdAt')
  ])
]);
