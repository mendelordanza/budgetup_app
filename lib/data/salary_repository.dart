import 'package:budgetup_app/domain/salary.dart';

import 'local/isar_service.dart';

class SalaryRepository {
  final IsarService _isarService;

  const SalaryRepository({
    required IsarService isarService,
  }) : _isarService = isarService;

  Future<Salary?> getSalaryByDate(DateTime date) async {
    final category = await _isarService.getSalary(date);
    if (category != null) {
      return Salary.fromJson(category.toJson());
    }
    return null;
  }

  Future<void> saveSalary(Salary salary) async {
    await _isarService.saveSalary(salary.toIsar());
  }
}
