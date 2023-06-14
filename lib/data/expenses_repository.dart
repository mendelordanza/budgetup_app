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
    _isarService.deleteAllTxns(categoryId).then((value) {
      _isarService.deleteExpenseCategory(categoryId);
    });
  }

  Future<void> saveCategory(ExpenseCategory category) async {
    final isarObject = ExpenseCategoryEntity()
      ..id = category.id != null ? category.id! : Isar.autoIncrement
      ..icon = category.icon
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
      ..createdAt = expenseTxn.createdAt
      ..updatedAt = expenseTxn.updatedAt;

    if (category.id != null) {
      _isarService.addTransaction(category.toIsar(txnObject));
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
      _isarService.editTransaction(txnObject);
    }
  }

  Future<void> deleteTransaction(int txnId) async {
    _isarService.deleteTransaction(txnId);
  }
}
