import 'dart:convert';

import 'package:budgetup_app/data/local/entities/currency_rate_entity.dart';
import 'package:budgetup_app/data/local/entities/expense_category_entity.dart';
import 'package:budgetup_app/data/local/entities/expense_txn_entity.dart';
import 'package:budgetup_app/data/local/entities/recurring_bill_entity.dart';
import 'package:budgetup_app/data/local/entities/recurring_bill_txn_entity.dart';
import 'package:budgetup_app/data/local/entities/salary_entity.dart';
import 'package:budgetup_app/domain/recurring_bill.dart';
import 'package:budgetup_app/helper/date_helper.dart';
import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:budgetup_app/injection_container.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/expense_category.dart';
import 'backup/file_manager.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<void> saveSalary(SalaryEntity salaryEntity) async {
    final isar = await db;
    isar.writeTxnSync<int>(() => isar.salaryEntitys.putSync(salaryEntity));
  }

  Future<SalaryEntity?> getSalary(DateTime date) async {
    final isar = await db;
    final salary = await isar.salaryEntitys
        .where()
        .filter()
        .monthEqualTo(date.month)
        .and()
        .yearEqualTo(date.year)
        .findFirst();
    return salary;
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

  Future<List<ExpenseTxnEntity>> getAllTransactions() async {
    final isar = await db;
    final list = await isar.expenseTxnEntitys.where().findAll();
    return list;
  }

  Future<List<ExpenseCategoryEntity>> getAllExpenseCategories() async {
    final isar = await db;
    final list = await isar.expenseCategoryEntitys.where().findAll();
    return list;
  }

  Future<ExpenseCategoryEntity?> getCategoryById(int categoryId) async {
    final isar = await db;
    final category = await isar.expenseCategoryEntitys.get(categoryId);
    return category;
  }

  Future<List<ExpenseCategoryEntity>> getAllExpenseCategoriesByDate(
      DateTime date) async {
    final isar = await db;
    final list = await isar.expenseCategoryEntitys
        .where()
        .filter()
        .expenseTransactions((q) => q.updatedAtBetween(
            getFirstDayOfMonth(date), getLastDayOfMonth(date)))
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

  Future<bool> bulkAddCategories({
    required List<ExpenseCategoryEntity> updatedCategories,
    required List<ExpenseTxnEntity> updatedTxns,
  }) async {
    final isar = await db;
    final success = isar.writeTxnSync(() {
      isar.expenseCategoryEntitys.clearSync();
      isar.expenseTxnEntitys.clearSync();
      isar.expenseCategoryEntitys.putAllSync(updatedCategories);
      final expensesAdded = isar.expenseTxnEntitys.putAllSync(updatedTxns);
      return expensesAdded.isNotEmpty;
    });
    return success;
  }

  Future<bool> bulkAddRecurringBills({
    required List<RecurringBillEntity> updatedRecurringBills,
    required List<RecurringBillTxnEntity> updatedRecurringBillTxns,
  }) async {
    final isar = await db;
    final success = isar.writeTxnSync(() {
      isar.recurringBillEntitys.clearSync();
      isar.recurringBillTxnEntitys.clearSync();
      isar.recurringBillEntitys.putAllSync(updatedRecurringBills);
      final recurringBillsAdded =
          isar.recurringBillTxnEntitys.putAllSync(updatedRecurringBillTxns);
      return recurringBillsAdded.isNotEmpty;
    });
    return success;
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
    await isar.writeTxn<int>(
        () async => await isar.expenseTxnEntitys.put(expenseTxn));
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
    DateFilterType selectedDateFilterType,
    DateTime datePaid,
  ) async {
    final isar = await db;

    switch (selectedDateFilterType) {
      case DateFilterType.daily:
        return await isar.recurringBillEntitys
            .where()
            .filter()
            .recurringBillTxns((q) => q.datePaidBetween(
                removeTimeFromDate(datePaid), getEndOfDay(datePaid)))
            .findAll();
      case DateFilterType.weekly:
        return await isar.recurringBillEntitys
            .where()
            .filter()
            .recurringBillTxns((q) => q.datePaidBetween(
                removeTimeFromDate(getStartOfWeek((datePaid))),
                removeTimeFromDate(getEndOfWeek((datePaid)))))
            .findAll();
      case DateFilterType.monthly:
        return await isar.recurringBillEntitys
            .where()
            .filter()
            .recurringBillTxns((q) => q.datePaidBetween(
                getFirstDayOfMonth(datePaid), getLastDayOfMonth(datePaid)))
            .findAll();
    }
  }

  Future<int> saveRecurringBill(RecurringBillEntity recurringBillEntity) async {
    final isar = await db;
    return isar.writeTxnSync<int>(
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

  Future<void> softDeleteRecurringBill(
    RecurringBillEntity recurringBillEntity,
    DateTime selectedDate,
  ) async {
    final isar = await db;

    final sharedPrefs = getIt<SharedPrefs>();
    final convertedAmount = sharedPrefs.getCurrencyCode() == "USD"
        ? (recurringBillEntity.amount ?? 0.00)
        : (recurringBillEntity.amount ?? 0.00) / sharedPrefs.getCurrencyRate();

    await isar.writeTxn(() async {
      final success =
          await isar.recurringBillEntitys.put(recurringBillEntity.copy(
        amount: convertedAmount,
        archived: true,
        archivedDate: removeTimeFromDate(selectedDate),
      ));
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

  Future<bool> importFromJson() async {
    final jsonString = await FileManager().readJsonFile();
    final categoriesData = jsonString["expenseCategories"];
    final recurringBillsData = jsonString["recurringBills"];

    final categories = List<ExpenseCategory>.from(categoriesData.map((txn) {
      final category = ExpenseCategory.fromJsonFile(txn);
      return category;
    }));

    final isarCategories = categories.map((e) {
      return e.toIsar();
    }).toList();

    List<ExpenseTxnEntity> isarCategoryTxns = [];
    categories.forEach((category) {
      category.expenseTransactions?.forEach((txn) {
        isarCategoryTxns.add(txn.toIsar(category: category));
      });
    });

    final recurringBills =
        List<RecurringBill>.from(recurringBillsData.map((bill) {
      return RecurringBill.fromJsonFile(bill);
    }));

    final isarBills = recurringBills.map((e) {
      return e.toIsar();
    }).toList();
    List<RecurringBillTxnEntity> isarBillsTxns = [];
    recurringBills.forEach((bill) {
      bill.recurringBillTxns?.forEach((billTxn) {
        isarBillsTxns.add(billTxn.toIsar(bill: bill));
      });
    });

    bulkAddRecurringBills(
      updatedRecurringBills: isarBills,
      updatedRecurringBillTxns: isarBillsTxns,
    );
    return bulkAddCategories(
      updatedCategories: isarCategories,
      updatedTxns: isarCategoryTxns,
    );
  }

  Future<bool> exportToJson() async {
    final recurringBills = await getAllRecurringBills();
    final jsonRecurringBills = recurringBills.map((recurringBillEntity) {
      final bill = RecurringBill.fromJson(recurringBillEntity.toJson());
      return bill.toJson();
    }).toList();

    final categories = await getAllExpenseCategories();
    final jsonCategories = categories.map((categoryEntity) {
      final category = ExpenseCategory.fromJson(categoryEntity.toJson());
      return category.toJson();
    }).toList();
    final all = {
      "expenseCategories": jsonCategories,
      "recurringBills": jsonRecurringBills
    };
    return FileManager().writeJsonFile(jsonEncode(all));
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
          SalaryEntitySchema,
        ],
        inspector: true,
        directory: dir.path,
      );
    }
    return Future.value(Isar.getInstance());
  }
}
