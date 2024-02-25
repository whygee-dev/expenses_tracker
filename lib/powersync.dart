import 'dart:convert';

import 'package:expenses_tracker/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:http/http.dart' as http;

import './models/schema.dart';
import 'consts.dart';

final log = Logger('expenses-tracker');

class BackendConnector extends PowerSyncBackendConnector {
  PowerSyncDatabase db;

  BackendConnector(this.db);

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return null;
    }
    final idToken = await user.getIdToken();

    var url = Uri.parse("$backendUrl/api/auth/token");

    Map<String, String> headers = {
      'Authorization': 'Bearer $idToken',
      'Content-Type': 'application/json',
    };

    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode != 200) {
      return null;
    }

    final body = response.body;
    Map<String, dynamic> parsedBody = jsonDecode(body);
    final expiresAt = parsedBody['expiresAt'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            parsedBody['expiresAt']! * 1000,
          );

    return PowerSyncCredentials(
      endpoint: parsedBody['powerSyncUrl'],
      token: parsedBody['token'],
      userId: parsedBody['userId'],
      expiresAt: expiresAt,
    );
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    try {
      var transaction = await database.getNextCrudTransaction();

      if (transaction == null) {
        return;
      }

      for (var op in transaction.crud) {
        var row = op.opData == null ? {} : Map<String, dynamic>.of(op.opData!);
        row['id'] = op.id;
        Map<String, dynamic> data = {"table": op.table, "data": row};

        if (op.op == UpdateType.put) {
          await upsert(data);
        } else if (op.op == UpdateType.patch) {
          await update(data);
        } else if (op.op == UpdateType.delete) {
          await delete(data);
        }
      }

      await transaction.complete();
    } catch (e) {
      log.severe('Failed to update object $e');
    }
  }
}

late final PowerSyncDatabase db;

upsert(data) async {
  var user = getUser();

  if (user == null) {
    log.severe('User not logged in');
    return;
  }

  var url = Uri.parse("$backendUrl/api/data");

  try {
    var response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await user.getIdToken()}',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      log.info('PUT request successful: ${response.body}');
    } else {
      log.severe('PUT request failed with status: ${response.statusCode}');
      throw Exception('PUT request failed with status: ${response.statusCode}');
    }
  } catch (e) {
    log.severe('Exception occurred: $e');
    rethrow;
  }
}

update(data) async {
  var user = getUser();

  if (user == null) {
    log.severe('User not logged in');
    return;
  }

  var url = Uri.parse("$backendUrl/api/data");

  try {
    var response = await http.patch(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await user.getIdToken()}',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      log.info('PUT request successful: ${response.body}');
    } else {
      log.severe('PUT request failed with status: ${response.statusCode}');
      throw Exception('PUT request failed with status: ${response.statusCode}');
    }
  } catch (e) {
    log.severe('Exception occurred: $e');
    rethrow;
  }
}

delete(data) async {
  var user = getUser();

  if (user == null) {
    log.severe('User not logged in');
    return;
  }

  var url = Uri.parse("$backendUrl/api/data");

  try {
    var response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await user.getIdToken()}',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      log.info('DELETE request successful: ${response.body}');
    } else {
      log.severe('DELETE request failed with status: ${response.statusCode}');
      throw Exception(
          'DELETE request failed with status: ${response.statusCode}');
    }
  } catch (e) {
    log.severe('Exception occurred: $e');
    rethrow;
  }
}

isLoggedIn() {
  final user = FirebaseAuth.instance.currentUser;

  return user != null;
}

String? getUserId() {
  final user = FirebaseAuth.instance.currentUser;

  return user!.uid;
}

User? getUser() {
  return FirebaseAuth.instance.currentUser;
}

Future<String> getDatabasePath() async {
  final dir = await getApplicationSupportDirectory();
  return join(dir.path, 'expenses-tracker.db');
}

Future<void> openDatabase() async {
  db = PowerSyncDatabase(schema: schema, path: await getDatabasePath());
  await db.initialize();
  BackendConnector? currentConnector;

  await initFirebase();

  final userLoggedIn = isLoggedIn();

  if (userLoggedIn) {
    currentConnector = BackendConnector(db);
    db.connect(connector: currentConnector);
  } else {
    log.info('User not logged in, setting connection');
  }

  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    if (user != null) {
      currentConnector = BackendConnector(db);
      db.connect(connector: currentConnector!);
    } else {
      currentConnector = null;
      await db.disconnect();
    }
  });
}

Future<void> logout() async {
  await FirebaseAuth.instance.signOut();
  await db.disconnectAndClear();
}
