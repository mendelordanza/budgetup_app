import 'package:budgetup_app/data/local/entities/recurring_bill_txn_entity.dart';
import 'package:isar/isar.dart';

part 'recurring_bill_entity.g.dart';

@collection
class RecurringBillEntity {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment

  String? title;
  double? amount;
  String? interval;
  DateTime? reminderDate;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? archived;
  DateTime? archivedDate;
  final recurringBillTxns = IsarLinks<RecurringBillTxnEntity>();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'interval': interval,
      'reminderDate': reminderDate,
      'recurringBillTxns': recurringBillTxns,
      'archived': archived,
      'archivedDate': archivedDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  RecurringBillEntity copy({
    int? id,
    String? title,
    double? amount,
    String? interval,
    DateTime? reminderDate,
    bool? archived,
    DateTime? archivedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      RecurringBillEntity()
        ..id = id ?? this.id
        ..title = title ?? this.title
        ..amount = amount ?? this.amount
        ..interval = interval ?? this.interval
        ..reminderDate = reminderDate ?? this.reminderDate
        ..archived = archived ?? this.archived
        ..archivedDate = archivedDate ?? this.archivedDate
        ..createdAt = createdAt ?? this.createdAt
        ..updatedAt = updatedAt ?? this.updatedAt;
}
