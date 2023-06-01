
import 'local/isar_service.dart';

class RecurringBillsRepository {
  final IsarService _isarService;

  const RecurringBillsRepository({
    required IsarService isarService,
  }) : _isarService = isarService;
}