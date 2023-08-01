import 'package:budgetup_app/data/local/entities/recurring_bill_entity.dart';
import 'package:budgetup_app/data/local/entities/recurring_bill_txn_entity.dart';
import 'package:budgetup_app/domain/recurring_bill.dart';
import 'package:budgetup_app/domain/recurring_bill_txn.dart';
import 'package:budgetup_app/helper/shared_prefs.dart';

import '../helper/date_helper.dart';
import 'local/isar_service.dart';

class RecurringBillsRepository {
  final IsarService isarService;
  final SharedPrefs sharedPrefs;

  const RecurringBillsRepository({
    required this.isarService,
    required this.sharedPrefs,
  });

  Future<List<RecurringBill>> getRecurringBills() async {
    final objects = await isarService.getAllRecurringBills();
    final recurringBills = objects.map((category) {
      return RecurringBill.fromJson(category.toJson());
    }).toList();

    final convertedRecurringBills = recurringBills.map((bill) {
      final convertedAmount = sharedPrefs.getCurrencyCode() == "USD"
          ? (bill.amount ?? 0.00)
          : (bill.amount ?? 0.00) * sharedPrefs.getCurrencyRate();
      return bill.copy(amount: convertedAmount);
    }).toList();

    return convertedRecurringBills;
  }

  Future<List<RecurringBill>> getPaidRecurringBills(
    DateFilterType selectedDateFilterType,
    DateTime datePaid,
  ) async {
    final objects = await isarService.getPaidRecurringBills(
        selectedDateFilterType, datePaid);
    final paidRecurringBills = objects.map((category) {
      return RecurringBill.fromJson(category.toJson());
    }).toList();

    //CONVERT
    final convertedPaidRecurringBills = paidRecurringBills.map((bill) {
      final convertedAmount = sharedPrefs.getCurrencyCode() == "USD"
          ? (bill.amount ?? 0.00)
          : (bill.amount ?? 0.00) * sharedPrefs.getCurrencyRate();
      return bill.copy(amount: convertedAmount);
    }).toList();

    return convertedPaidRecurringBills;
  }

  Future<int> saveRecurringBill(
    RecurringBill recurringBill,
  ) async {
    final newRecurringBill = recurringBill.toIsar();
    return await isarService.saveRecurringBill(newRecurringBill);
  }

  Future<void> softDeleteRecurringBill(
    RecurringBill recurringBill,
    DateTime selectedDate,
  ) async {
    final recurringBillEntity = recurringBill.toIsar();
    await isarService.softDeleteRecurringBill(
      recurringBillEntity,
      selectedDate,
    );
  }

  //TODO add identification for delete all
  Future<void> deleteRecurringBill(int recurringBillId) async {
    await isarService.deleteAllRecurringBillTxns(recurringBillId);
    await isarService.deleteRecurringBill(recurringBillId);
  }

  Future<void> addRecurringBillTxn(
    RecurringBill recurringBill,
    RecurringBillTxn recurringBillTxn,
  ) async {
    final newRecurringBillObject = RecurringBillEntity()
      ..id = recurringBill.id!
      ..title = recurringBill.title
      ..amount = recurringBill.amount
      ..reminderDate = recurringBill.reminderDate
      ..createdAt = recurringBill.createdAt
      ..updatedAt = DateTime.now();

    final txnObject = RecurringBillTxnEntity()
      ..isPaid = recurringBillTxn.isPaid
      ..datePaid = recurringBillTxn.datePaid
      ..recurringBill.value = newRecurringBillObject;

    isarService.addRecurringBillTxn(txnObject);
  }

  Future<void> deleteRecurringBillTxn(
    RecurringBillTxn recurringBillTxn,
  ) async {
    if (recurringBillTxn.id != null) {
      isarService.deleteRecurringBillTxn(recurringBillTxn.id!);
    }
  }
}
