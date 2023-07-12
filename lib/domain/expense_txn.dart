import 'package:budgetup_app/data/local/entities/expense_txn_entity.dart';
import 'package:equatable/equatable.dart';

import 'expense_category.dart';

class ExpenseTxn extends Equatable {
  final int? id;
  final String? notes;
  final double? amount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ExpenseTxn({
    this.id,
    this.notes,
    this.amount,
    this.createdAt,
    this.updatedAt,
  });

  factory ExpenseTxn.fromJson(Map<dynamic, dynamic> json) => ExpenseTxn(
        id: json["id"],
        notes: json["notes"],
        amount: json["amount"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
      );

  factory ExpenseTxn.fromJsonFile(Map<dynamic, dynamic> json) => ExpenseTxn(
        id: json["id"],
        notes: json["notes"],
        amount: json["amount"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "notes": notes,
        "amount": amount,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String()
      };

  ExpenseTxn copy({
    int? id,
    String? notes,
    double? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
    ExpenseCategory? category,
  }) =>
      ExpenseTxn(
        id: id ?? this.id,
        notes: notes ?? this.notes,
        amount: amount ?? this.amount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  ExpenseTxnEntity toIsar({required ExpenseCategory category}) {
    final isarObject = ExpenseTxnEntity()
      ..amount = amount
      ..notes = notes
      ..category.value = category.toIsar()
      ..createdAt = createdAt
      ..updatedAt = updatedAt;
    return isarObject;
  }

  @override
  List<Object?> get props => [
        id,
        notes,
        amount,
        createdAt,
        updatedAt,
      ];
}
