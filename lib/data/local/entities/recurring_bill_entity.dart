import 'package:budgetup_app/data/local/entities/recurring_bill_txn_entity.dart';
import 'package:isar/isar.dart';

part 'recurring_bill_entity.g.dart';

@collection
class RecurringBillEntity {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment

  String? title;
  double? amount;
  DateTime? createdAt;
  DateTime? updatedAt;
  final recurringBillTxns = IsarLinks<RecurringBillTxnEntity>();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'recurringBillTxns': recurringBillTxns,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
