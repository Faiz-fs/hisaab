import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repos/rule_service.dart';
import 'db_provider.dart';

final ruleServiceProvider = Provider<RuleService>(
  (ref) => RuleService(ref.watch(dbProvider)),
);
