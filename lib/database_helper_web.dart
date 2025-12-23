import 'package:drift/drift.dart';
import 'package:drift/web.dart';

LazyDatabase createConnection() {
  return LazyDatabase(() async {
    // WebDatabase will use sql.js from the global scope
    // Make sure sql.js is loaded in index.html before this runs
    return WebDatabase('db');
  });
}

