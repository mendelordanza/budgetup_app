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

  Future<List<ExpenseTxn>> getAllTransactions() async {
    final objects = await _isarService.getAllTransactions();
    return objects.map((txn) {
      return ExpenseTxn.fromJson(txn.toJson()).copy(
        categoryId: txn.category.value?.id,
        categoryTitle:
            "${txn.category.value?.icon} ${txn.category.value?.title}",
      );
    }).toList();
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
    if (category.id != null) {
      await _isarService.addTransaction(expenseTxn.toIsar(category: category));
    }
  }

  Future<void> editTransaction(ExpenseTxn expenseTxn) async {
    final txnObject = ExpenseTxnEntity()
      ..id = expenseTxn.id != null ? expenseTxn.id! : Isar.autoIncrement
      ..notes = expenseTxn.notes
      ..amount = expenseTxn.amount
      ..createdAt = expenseTxn.createdAt
      ..updatedAt = expenseTxn.updatedAt;

    await _isarService.editTransaction(txnObject);
  }

  Future<void> deleteTransaction(int txnId) async {
    await _isarService.deleteTransaction(txnId);
  }
}
