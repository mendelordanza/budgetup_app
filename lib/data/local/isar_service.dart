import 'dart:math';

import 'package:budgetup_app/data/local/entities/expense_category_entity.dart';
import 'package:budgetup_app/data/local/entities/expense_txn_entity.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<void> saveExpenseCategory(
      ExpenseCategoryEntity expenseCategory) async {
    final isar = await db;
    isar.writeTxnSync<int>(
        () => isar.expenseCategoryEntitys.putSync(expenseCategory));
  }

  Future<void> deleteExpenseCategory(int categoryId) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final success = await isar.expenseCategoryEntitys.delete(categoryId);
      print('deleted: $success');
    });
  }

  Future<void> deleteAllTxns(int categoryId) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final success = await isar.expenseTxnEntitys
          .where()
          .filter()
          .category((q) => q.idEqualTo(categoryId))
          .deleteAll();
      print('deleted: $success');
    });
  }

  Future<void> addTransaction(ExpenseCategoryEntity expenseCategory) async {
    final isar = await db;
    isar.writeTxnSync<int>(
        () => isar.expenseCategoryEntitys.putSync(expenseCategory));
  }

  Future<List<ExpenseCategoryEntity>> getAllExpenseCategories() async {
    final isar = await db;
    return await isar.expenseCategoryEntitys.where().findAll();
  }

  Future<List<ExpenseTxnEntity>> getAllExpenseTxns() async {
    final isar = await db;
    return await isar.expenseTxnEntitys.where().findAll();
  }

  Future<double> getTotal(int categoryId) async {
    final isar = await db;
    return await isar.expenseTxnEntitys
        .where()
        .filter()
        .category((q) => q.idEqualTo(categoryId))
        .amountProperty()
        .sum();
  }

  Future<void> cleanDb() async {
    final isar = await db;
    await isar.writeTxn(() => isar.clear());
  }

  Future<List<ExpenseTxnEntity>> getExpenseTxnFor(int categoryId) async {
    final isar = await db;
    return await isar.expenseTxnEntitys
        .filter()
        .category((q) => q.idEqualTo(categoryId))
        .findAll();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [ExpenseCategoryEntitySchema, ExpenseTxnEntitySchema],
        inspector: true,
        directory: dir.path,
      );
    }

    return Future.value(Isar.getInstance());
  }
}
