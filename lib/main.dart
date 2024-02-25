import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import './powersync.dart';

import 'pages/expenses.dart';
import 'pages/login.dart';
import 'pages/signup.dart';

void main() async {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print(
          '[${record.loggerName}] ${record.level.name}: ${record.time}: ${record.message}');

      if (record.error != null) {
        print(record.error);
      }
      if (record.stackTrace != null) {
        print(record.stackTrace);
      }
    }
  });

  WidgetsFlutterBinding.ensureInitialized();
  await openDatabase();
  final loggedIn = isLoggedIn();

  if (kDebugMode) {
    print('Logged in: $loggedIn');
  }

  runApp(App(loggedIn: loggedIn));
}

const expensesPage = ExpensesPage();

const loginPage = LoginPage();

const signupPage = SignupPage();

class App extends StatelessWidget {
  final bool loggedIn;

  const App({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expenses Tracker',
      home: loggedIn ? expensesPage : loginPage,
      debugShowCheckedModeBanner: false,
    );
  }
}
