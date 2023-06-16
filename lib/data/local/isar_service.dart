import 'package:budgetup_app/data/local/entities/currency_rate_entity.dart';
import 'package:budgetup_app/data/local/entities/expense_category_entity.dart';
import 'package:budgetup_app/data/local/entities/expense_txn_entity.dart';
import 'package:budgetup_app/data/local/entities/recurring_bill_entity.dart';
import 'package:budgetup_app/data/local/entities/recurring_bill_txn_entity.dart';
import 'package:budgetup_app/helper/date_helper.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<double> getTotalExpenseByDate(DateTime date) async {
    final isar = await db;
    var total = 0.00;
    final amountList = await isar.expenseTxnEntitys
        .where()
        .filter()
        .updatedAtLessThan(date)
        .amountProperty()
        .findAll();
    amountList.forEach((element) {
      total += element ?? 0.0;
    });
    return total;
  }

  Future<List<ExpenseCategoryEntity>> getAllExpenseCategories() async {
    final isar = await db;
    final list = await isar.expenseCategoryEntitys.where().findAll();
    return list;
  }

  Future<List<ExpenseCategoryEntity>> getAllExpenseCategoriesByDate(
      DateTime date) async {
    final isar = await db;
    final list = await isar.expenseCategoryEntitys
        .where()
        .filter()
        .expenseTransactions(
            (q) => q.updatedAtGreaterThan(getFirstDayOfMonth(date)))
        .expenseTransactions(
            (q) => q.updatedAtLessThan(getLastDayOfMonth(date)))
        .findAll();
    return list;
  }

  Future<void> saveExpenseCategory(
      ExpenseCategoryEntity expenseCategory) async {
    final isar = await db;
    isar.writeTxnSync<int>(
        () => isar.expenseCategoryEntitys.putSync(expenseCategory));
  }

  Future<bool> deleteExpenseCategory(int categoryId) async {
    final isar = await db;
    return await isar.writeTxn(() async {
      final success = await isar.expenseCategoryEntitys.delete(categoryId);
      return success;
    });
  }

  Future<void> bulkEditCategory(
    List<ExpenseCategoryEntity> updatedCategories,
  ) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final success =
          await isar.expenseCategoryEntitys.putAll(updatedCategories);
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

  Future<void> addTransaction(ExpenseTxnEntity expenseTxnEntity) async {
    final isar = await db;
    isar.writeTxnSync<int>(
        () => isar.expenseTxnEntitys.putSync(expenseTxnEntity));
  }

  Future<void> editTransaction(ExpenseTxnEntity expenseTxn) async {
    final isar = await db;
    isar.writeTxnSync<int>(() => isar.expenseTxnEntitys.putSync(expenseTxn));
  }

  Future<void> bulkEditTxns(List<ExpenseTxnEntity> updatedTxns) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final success = await isar.expenseTxnEntitys.putAll(updatedTxns);
      print('deleted: $success');
    });
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
        .sortByUpdatedAtDesc()
        .findAll();
  }

  Future<List<RecurringBillEntity>> getAllRecurringBills() async {
    final isar = await db;
    return await isar.recurringBillEntitys.where().findAll();
  }

  Future<List<RecurringBillEntity>> getPaidRecurringBills(
      DateTime datePaid) async {
    final isar = await db;
    return await isar.recurringBillEntitys
        .where()
        .filter()
        .recurringBillTxns(
            (q) => q.datePaidGreaterThan(getFirstDayOfMonth(datePaid)))
        .recurringBillTxns(
            (q) => q.datePaidLessThan(getLastDayOfMonth(datePaid)))
        .findAll();
  }

  Future<void> saveRecurringBill(
      RecurringBillEntity recurringBillEntity) async {
    final isar = await db;
    isar.writeTxnSync<int>(
        () => isar.recurringBillEntitys.putSync(recurringBillEntity));
  }

  Future<void> addRecurringBillTxn(
      RecurringBillTxnEntity recurringBillTxnEntity) async {
    final isar = await db;
    isar.writeTxnSync<int>(
        () => isar.recurringBillTxnEntitys.putSync(recurringBillTxnEntity));
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
    isar.writeTxnSync(() {
      final success = isar.recurringBillTxnEntitys.deleteSync(txnId);
      print('deleted: $success');
    });
  }

  Future<void> addCurrency(CurrencyRateEntity currencyRateEntity) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.currencyRateEntitys.put(currencyRateEntity);
    });
  }

  Future<List<CurrencyRateEntity>> getAllCurrencies() async {
    final isar = await db;
    final list = await isar.currencyRateEntitys.where().findAll();
    return list;
  }

  Future<void> deleteAllCurrencies() async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.currencyRateEntitys.clear();
    });
  }

  Future<CurrencyRateEntity?> getCurrencyRate(String currencyCode) async {
    final isar = await db;
    final list = await isar.currencyRateEntitys
        .where()
        .filter()
        .countryEqualTo(currencyCode)
        .findFirst();
    return list;
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
          CurrencyRateEntitySchema,
        ],
        inspector: true,
        directory: dir.path,
      );
    }

    return Future.value(Isar.getInstance());
  }
}
