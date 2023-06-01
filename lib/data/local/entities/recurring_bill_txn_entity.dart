import 'package:budgetup_app/data/local/entities/recurring_bill_entity.dart';
import 'package:isar/isar.dart';

part 'recurring_bill_txn_entity.g.dart';

@collection
class RecurringBillTxnEntity {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment

  bool isPaid = false;
  DateTime? datePaid;

  @Backlink(to: "recurringBillTxns")
  final recurringBill = IsarLink<RecurringBillEntity>();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isPaid': isPaid,
      'datePaid': datePaid,
    };
  }
}
