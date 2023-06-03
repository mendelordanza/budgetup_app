import 'package:budgetup_app/data/local/entities/expense_category_entity.dart';
import 'package:budgetup_app/data/local/entities/expense_txn_entity.dart';
import 'package:budgetup_app/data/local/entities/recurring_bill_entity.dart';
import 'package:budgetup_app/data/local/entities/recurring_bill_txn_entity.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<List<ExpenseCategoryEntity>> getAllExpenseCategories(
      DateTime selectedDate) async {
    print(selectedDate);
    final isar = await db;
    return await isar.expenseCategoryEntitys.where().findAll();
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

  Future<void> editTransaction(ExpenseTxnEntity expenseTxn) async {
    final isar = await db;
    isar.writeTxnSync<int>(() => isar.expenseTxnEntitys.putSync(expenseTxn));
  }

  Future<void> deleteTransaction(int txnId) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final success = await isar.expenseTxnEntitys.delete(txnId);
      print('deleted: $success');
    });
  }

  Future<List<ExpenseTxnEntity>> getExpenseTxnFor(int categoryId) async {
    final isar = await db;
    return await isar.expenseTxnEntitys
        .filter()
        .category((q) => q.idEqualTo(categoryId))
        .findAll();
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

  Future<List<RecurringBillEntity>> getAllRecurringBills() async {
    final isar = await db;
    return await isar.recurringBillEntitys.where().findAll();
  }

  Future<void> saveRecurringBill(
      RecurringBillEntity recurringBillEntity) async {
    final isar = await db;
    isar.writeTxnSync<int>(
        () => isar.recurringBillEntitys.putSync(recurringBillEntity));
  }

  Future<void> deleteRecurringBill(int recurringBillId) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final success = await isar.recurringBillEntitys.delete(recurringBillId);
      print('deleted: $success');
    });
  }

  Future<void> deleteAllRecurringBillTxns(int recurringBillId) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final success = await isar.recurringBillTxnEntitys
          .where()
          .filter()
          .recurringBill((q) => q.idEqualTo(recurringBillId))
          .deleteAll();
      print('deleted: $success');
    });
  }

  Future<void> deleteRecurringBillTxn(int txnId) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final success = await isar.recurringBillTxnEntitys.delete(txnId);
      print('deleted: $success');
    });
  }

  Future<void> cleanDb() async {
    final isar = await db;
    await isar.writeTxn(() => isar.clear());
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [
          ExpenseCategoryEntitySchema,
          ExpenseTxnEntitySchema,
          RecurringBillEntitySchema,
          RecurringBillTxnEntitySchema,
        ],
        inspector: true,
        directory: dir.path,
      );
    }

    return Future.value(Isar.getInstance());
  }
}
