import 'package:budgetup_app/data/local/entities/recurring_bill_entity.dart';
import 'package:budgetup_app/data/local/entities/recurring_bill_txn_entity.dart';
import 'package:budgetup_app/domain/recurring_bill.dart';
import 'package:budgetup_app/domain/recurring_bill_txn.dart';
import 'package:isar/isar.dart';

import 'local/isar_service.dart';

class RecurringBillsRepository {
  final IsarService _isarService;

  const RecurringBillsRepository({
    required IsarService isarService,
  }) : _isarService = isarService;

  Future<List<RecurringBill>> getRecurringBills() async {
    final objects = await _isarService.getAllRecurringBills();
    return objects.map((category) {
      return RecurringBill.fromJson(category.toJson());
    }).toList();
  }

  Future<List<RecurringBill>> getPaidRecurringBills(DateTime datePaid) async {
    final objects = await _isarService.getPaidRecurringBills(datePaid);
    return objects.map((category) {
      return RecurringBill.fromJson(category.toJson());
    }).toList();
  }

  Future<void> saveRecurringBill(
    RecurringBill recurringBill,
  ) async {
    final newRecurringBill = RecurringBillEntity()
      ..id = recurringBill.id != null ? recurringBill.id! : Isar.autoIncrement
      ..title = recurringBill.title
      ..amount = recurringBill.amount
      ..reminderDate = recurringBill.reminderDate
      ..createdAt = recurringBill.createdAt
      ..updatedAt = recurringBill.updatedAt;
    _isarService.saveRecurringBill(newRecurringBill);
  }

  Future<void> deleteRecurringBill(int recurringBillId) async {
    _isarService.deleteAllRecurringBillTxns(recurringBillId).then((value) {
      _isarService.deleteRecurringBill(recurringBillId);
    });
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

    _isarService.addRecurringBillTxn(txnObject);
  }

  Future<void> deleteRecurringBillTxn(
    RecurringBillTxn recurringBillTxn,
  ) async {
    if (recurringBillTxn.id != null) {
      _isarService.deleteRecurringBillTxn(recurringBillTxn.id!);
    }
  }
}
