import 'package:isar/isar.dart';

import 'expense_category_entity.dart';

part 'expense_txn_entity.g.dart';

@collection
class ExpenseTxnEntity {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment

  String? notes;
  double? amount;

  @Index()
  DateTime? createdAt;

  DateTime? updatedAt;

  @Backlink(to: "expenseTransactions")
  var category = IsarLink<ExpenseCategoryEntity>();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notes': notes,
      'amount': amount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
