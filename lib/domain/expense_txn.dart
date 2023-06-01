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

  Map<String, Object?> toJson() => {
        "id": id,
        "notes": notes,
        "amount": amount,
        "createdAt": createdAt,
        "updatedAt": updatedAt
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

  @override
  List<Object?> get props => [
        id,
        notes,
        amount,
        createdAt,
        updatedAt,
      ];
}
