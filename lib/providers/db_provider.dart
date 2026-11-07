import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/app_database.dart';

/// Global Riverpod provider for the singleton [AppDatabase] instance.
/// Disposed when the [ProviderScope] is disposed (app exit).
final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
