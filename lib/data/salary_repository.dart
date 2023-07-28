import 'package:budgetup_app/domain/salary.dart';
import 'package:budgetup_app/helper/shared_prefs.dart';

import 'local/isar_service.dart';

class SalaryRepository {
  final IsarService isarService;
  final SharedPrefs sharedPrefs;

  const SalaryRepository({
    required this.isarService,
    required this.sharedPrefs,
  });

  Future<Salary?> getSalaryByDate(DateTime date) async {
    final category = await isarService.getSalary(date);
    if (category != null) {
      final salary = Salary.fromJson(category.toJson());

      final convertedSalary = salary.copy(
          amount: sharedPrefs.getCurrencyCode() == "USD"
              ? (salary.amount ?? 0.00)
              : (salary.amount ?? 0.00) * sharedPrefs.getCurrencyRate());

      return convertedSalary;
    }
    return null;
  }

  Future<void> saveSalary(Salary salary) async {
    await isarService.saveSalary(salary.toIsar());
  }
}
