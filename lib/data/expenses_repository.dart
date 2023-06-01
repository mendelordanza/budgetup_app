import 'package:budgetup_app/data/local/entities/expense_category_entity.dart';
import 'package:budgetup_app/data/local/entities/expense_txn_entity.dart';
import 'package:budgetup_app/data/local/isar_service.dart';
import 'package:budgetup_app/domain/expense_category.dart';
import 'package:budgetup_app/domain/expense_txn.dart';

class ExpensesRepository {
  final IsarService _isarService;

  const ExpensesRepository({
    required IsarService isarService,
  }) : _isarService = isarService;

  Future<double> getTotal(int categoryId) async {
    final total = await _isarService.getTotal(categoryId);
    return total;
  }

  Future<List<ExpenseCategory>> getExpenseCategories() async {
    final objects = await _isarService.getAllExpenseCategories();
    return objects.map((category) {
      return ExpenseCategory.fromJson(category.toJson());
    }).toList();
  }

  Future<List<ExpenseTxn>> getExpenseTxns(int categoryId) async {
    final objects = await _isarService.getExpenseTxnFor(categoryId);
    return objects.map((category) {
      return ExpenseTxn.fromJson(category.toJson());
    }).toList();
  }

  Future<void> deleteCategory(int categoryId) async {
    _isarService.deleteAllTxns(categoryId).then((value) {
      _isarService.deleteExpenseCategory(categoryId);
    });
  }

  Future<void> saveCategory(ExpenseCategory category) async {
    final isarObject = ExpenseCategoryEntity()
      ..id = category.id!
      ..title = category.title
      ..budget = category.budget
      ..createdAt = category.createdAt
      ..updatedAt = category.updatedAt;
    _isarService.saveExpenseCategory(isarObject);
  }

  Future<void> addTransaction(
      ExpenseCategory category, ExpenseTxn expenseTxn) async {
    final txnObject = ExpenseTxnEntity()
      ..notes = expenseTxn.notes
      ..amount = expenseTxn.amount
      ..createdAt = category.createdAt
      ..updatedAt = category.updatedAt;

    if (category.id != null) {
      final categoryObject = ExpenseCategoryEntity()
        ..id = category.id!
        ..title = category.title
        ..budget = category.budget
        ..icon = category.icon
        ..expenseTransactions.add(txnObject)
        ..createdAt = category.createdAt
        ..updatedAt = category.updatedAt;

      _isarService.addTransaction(categoryObject);
    }
  }
}
