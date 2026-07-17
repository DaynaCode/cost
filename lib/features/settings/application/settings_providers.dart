import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/backup_service.dart';
import '../data/export_service.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.watch(appDatabaseProvider));
});

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});
