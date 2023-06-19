import 'package:budgetup_app/data/local/entities/expense_category_entity.dart';
import 'package:budgetup_app/data/local/entities/expense_txn_entity.dart';
import 'package:budgetup_app/data/local/isar_service.dart';
import 'package:budgetup_app/domain/expense_category.dart';
import 'package:budgetup_app/domain/expense_txn.dart';
import 'package:isar/isar.dart';

class ExpensesRepository {
  final IsarService _isarService;

  const ExpensesRepository({
    required IsarService isarService,
  }) : _isarService = isarService;

  Future<double> getTotalExpenseByDate(DateTime date) async {
    final total = await _isarService.getTotalExpenseByDate(date);
    return total;
  }

  Future<List<ExpenseCategory>> getExpenseCategories() async {
    final objects = await _isarService.getAllExpenseCategories();
    return objects.map((category) {
      return ExpenseCategory.fromJson(category.toJson());
    }).toList();
  }

  Future<ExpenseCategory> getExpenseCategoryById(int categoryId) async {
    final category = await _isarService.getCategoryById(categoryId);
    return ExpenseCategory.fromJson(category!.toJson());
  }

  Future<List<ExpenseCategory>> getExpenseCategoriesByDate(
      DateTime date) async {
    final objects = await _isarService.getAllExpenseCategoriesByDate(date);
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
    await _isarService.deleteAllTxns(categoryId);
    await _isarService.deleteExpenseCategory(categoryId);
  }

  Future<void> bulkEditCategory(
    List<ExpenseCategory> categories,
  ) async {
    final updatedCategories = categories.map((category) {
      final isarObject = ExpenseCategoryEntity()
        ..id = category.id != null ? category.id! : Isar.autoIncrement
        ..icon = category.icon
        ..title = category.title
        ..budget = category.budget
        ..createdAt = category.createdAt
        ..updatedAt = category.updatedAt;
      return isarObject;
    }).toList();

    await _isarService.bulkEditCategory(updatedCategories);
  }

  Future<void> saveCategory(ExpenseCategory category) async {
    final isarObject = ExpenseCategoryEntity()
      ..id = category.id != null ? category.id! : Isar.autoIncrement
      ..icon = category.icon
      ..title = category.title
      ..budget = category.budget
      ..createdAt = category.createdAt
      ..updatedAt = category.updatedAt;
    await _isarService.saveExpenseCategory(isarObject);
  }

  Future<void> addTransaction(
      ExpenseCategory category, ExpenseTxn expenseTxn) async {
    final txnObject = ExpenseTxnEntity()
      ..notes = expenseTxn.notes
      ..amount = expenseTxn.amount
      ..category.value = category.toIsar()
      ..createdAt = expenseTxn.createdAt
      ..updatedAt = expenseTxn.updatedAt;

    if (category.id != null) {
      await _isarService.addTransaction(txnObject);
    }
  }

  Future<void> editTransaction(ExpenseTxn expenseTxn) async {
    final txnObject = ExpenseTxnEntity()
      ..id = expenseTxn.id!
      ..notes = expenseTxn.notes
      ..amount = expenseTxn.amount
      ..createdAt = expenseTxn.createdAt
      ..updatedAt = expenseTxn.updatedAt;

    if (expenseTxn.id != null) {
      await _isarService.editTransaction(txnObject);
    }
  }

  Future<void> bulkEditTxns(List<ExpenseTxn> txns) async {
    final updatedTxns = txns.map((expenseTxn) {
      final txnObject = ExpenseTxnEntity()
        ..id = expenseTxn.id != null ? expenseTxn.id! : Isar.autoIncrement
        ..notes = expenseTxn.notes
        ..amount = expenseTxn.amount
        ..createdAt = expenseTxn.createdAt
        ..updatedAt = expenseTxn.updatedAt;
      return txnObject;
    }).toList();
    await _isarService.bulkEditTxns(updatedTxns);
  }

  Future<void> deleteTransaction(int txnId) async {
    await _isarService.deleteTransaction(txnId);
  }
}
