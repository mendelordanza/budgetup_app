import 'package:budgetup_app/data/local/entities/expense_category_entity.dart';
import 'package:budgetup_app/data/local/entities/expense_txn_entity.dart';
import 'package:budgetup_app/data/local/isar_service.dart';
import 'package:budgetup_app/domain/expense_category.dart';
import 'package:budgetup_app/domain/expense_txn.dart';
import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:isar/isar.dart';

class ExpensesRepository {
  final IsarService isarService;
  final SharedPrefs sharedPrefs;

  ExpensesRepository({
    required this.isarService,
    required this.sharedPrefs,
  });

  Future<List<ExpenseTxn>> getAllTransactions() async {
    final objects = await isarService.getAllTransactions();
    final txns = objects.map((txn) {
      return ExpenseTxn.fromJson(txn.toJson()).copy(
        categoryId: txn.category.value?.id,
        categoryTitle:
            "${txn.category.value?.icon} ${txn.category.value?.title}",
      );
    }).toList();

    final convertedTxns = txns.map((txn) {
      final convertedAmount = sharedPrefs.getCurrencyCode() == "USD"
          ? (txn.amount ?? 0.00)
          : (txn.amount ?? 0.00) * sharedPrefs.getCurrencyRate();
      final newTxn = txn.copy(
        amount: convertedAmount,
      );
      return newTxn;
    }).toList();

    return convertedTxns;
  }

  Future<List<ExpenseCategory>> getExpenseCategories() async {
    final objects = await isarService.getAllExpenseCategories();
    final dashboardCategories = objects.map((category) {
      return ExpenseCategory.fromJson(category.toJson());
    }).toList();

    //CONVERT CURRENCY
    final convertedCategories = dashboardCategories.map((category) {
      final convertedBudget = sharedPrefs.getCurrencyCode() == "USD"
          ? (category.budget ?? 0.00)
          : (category.budget ?? 0.00) * sharedPrefs.getCurrencyRate();

      final convertedTxns = category.expenseTransactions?.map((txn) {
        final convertedAmount = sharedPrefs.getCurrencyCode() == "USD"
            ? (txn.amount ?? 0.00)
            : (txn.amount ?? 0.00) * sharedPrefs.getCurrencyRate();
        final newTxn = txn.copy(
          amount: convertedAmount,
        );
        return newTxn;
      }).toList();

      final newCategory = category.copy(
        budget: convertedBudget,
        expenseTransactions: convertedTxns,
      );

      return newCategory;
    }).toList();

    return convertedCategories;
  }

  Future<ExpenseCategory> getExpenseCategoryById(int categoryId) async {
    final category = await isarService.getCategoryById(categoryId);
    return ExpenseCategory.fromJson(category!.toJson());
  }

  Future<List<ExpenseCategory>> getExpenseCategoriesByDate(
      DateTime date) async {
    final objects = await isarService.getAllExpenseCategoriesByDate(date);
    final dashboardCategories = objects.map((category) {
      return ExpenseCategory.fromJson(category.toJson());
    }).toList();

    //CONVERT CURRENCY
    final convertedCategories = dashboardCategories.map((category) {
      final convertedBudget = sharedPrefs.getCurrencyCode() == "USD"
          ? (category.budget ?? 0.00)
          : (category.budget ?? 0.00) * sharedPrefs.getCurrencyRate();

      final convertedTxns = category.expenseTransactions?.map((txn) {
        final convertedAmount = sharedPrefs.getCurrencyCode() == "USD"
            ? (txn.amount ?? 0.00)
            : (txn.amount ?? 0.00) * sharedPrefs.getCurrencyRate();
        final newTxn = txn.copy(
          amount: convertedAmount,
        );
        return newTxn;
      }).toList();

      final newCategory = category.copy(
        budget: convertedBudget,
        expenseTransactions: convertedTxns,
      );

      return newCategory;
    }).toList();

    return convertedCategories;
  }

  Future<List<ExpenseTxn>> getExpenseTxns(int categoryId) async {
    final objects = await isarService.getExpenseTxnFor(categoryId);
    final txns = objects.map((category) {
      return ExpenseTxn.fromJson(category.toJson());
    }).toList();

    final convertedTxns = txns.map((txn) {
      final convertedAmount = sharedPrefs.getCurrencyCode() == "USD"
          ? (txn.amount ?? 0.00)
          : (txn.amount ?? 0.00) * sharedPrefs.getCurrencyRate();
      final newTxn = txn.copy(
        amount: convertedAmount,
      );
      return newTxn;
    }).toList();

    return convertedTxns;
  }

  Future<void> deleteCategory(int categoryId) async {
    await isarService.deleteAllTxns(categoryId);
    await isarService.deleteExpenseCategory(categoryId);
  }

  Future<void> saveCategory(ExpenseCategory category) async {
    final isarObject = ExpenseCategoryEntity()
      ..id = category.id != null ? category.id! : Isar.autoIncrement
      ..icon = category.icon
      ..title = category.title
      ..budget = category.budget
      ..createdAt = category.createdAt
      ..updatedAt = category.updatedAt;
    await isarService.saveExpenseCategory(isarObject);
  }

  Future<void> addTransaction(
      ExpenseCategory category, ExpenseTxn expenseTxn) async {
    if (category.id != null) {
      await isarService.addTransaction(expenseTxn.toIsar(category: category));
    }
  }

  Future<void> editTransaction(ExpenseTxn expenseTxn) async {
    final txnObject = ExpenseTxnEntity()
      ..id = expenseTxn.id != null ? expenseTxn.id! : Isar.autoIncrement
      ..notes = expenseTxn.notes
      ..amount = expenseTxn.amount
      ..createdAt = expenseTxn.createdAt
      ..updatedAt = expenseTxn.updatedAt;

    await isarService.editTransaction(txnObject);
  }

  Future<void> deleteTransaction(int txnId) async {
    await isarService.deleteTransaction(txnId);
  }
}
