import 'package:budgetup_app/data/local/entities/expense_txn_entity.dart';
import 'package:isar/isar.dart';

part 'expense_category_entity.g.dart';

@collection
class ExpenseCategoryEntity {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment

  String? title;
  String? icon;
  double? budget;
  final expenseTransactions = IsarLinks<ExpenseTxnEntity>();
  DateTime? createdAt;
  DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'budget': budget,
      'expenseTransactions': expenseTransactions,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
