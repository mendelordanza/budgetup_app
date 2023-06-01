import 'package:budgetup_app/data/local/entities/recurring_bill_entity.dart';
import 'package:budgetup_app/data/local/entities/recurring_bill_txn_entity.dart';
import 'package:budgetup_app/domain/recurring_bill.dart';
import 'package:budgetup_app/domain/recurring_bill_txn.dart';

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

  Future<void> addRecurringBillTxn(
    RecurringBill recurringBill,
    RecurringBillTxn recurringBillTxn,
  ) async {
    final txnObject = RecurringBillTxnEntity()
      ..isPaid = recurringBillTxn.isPaid
      ..datePaid = recurringBillTxn.datePaid;

    final newRecurringBill = RecurringBillEntity()
      ..id = recurringBill.id!
      ..title = recurringBill.title
      ..amount = recurringBill.amount
      ..recurringBillTxns.add(txnObject)
      ..createdAt = recurringBill.createdAt
      ..updatedAt = DateTime.now();

    _isarService.addRecurringBill(newRecurringBill);
  }
}
