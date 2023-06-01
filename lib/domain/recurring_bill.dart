import 'package:budgetup_app/domain/recurring_bill_txn.dart';
import 'package:equatable/equatable.dart';

class RecurringBill extends Equatable {
  final int? id;
  final String? title;
  final double? amount;
  final List<RecurringBillTxn>? recurringBillTxns;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RecurringBill({
    this.id,
    this.title,
    this.amount,
    this.recurringBillTxns,
    this.createdAt,
    this.updatedAt,
  });

  factory RecurringBill.fromJson(Map<dynamic, dynamic> json) => RecurringBill(
        id: json["id"],
        title: json["title"],
        amount: json["amount"],
        recurringBillTxns: List<RecurringBillTxn>.from(json["recurringBillTxns"]
            .map((txn) => RecurringBillTxn.fromJson(txn.toJson()))),
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
      );

  Map<String, Object?> toJson() => {
        "id": id,
        "title": title,
        "amount": amount,
        "recurringBillTxns": recurringBillTxns,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
      };

  RecurringBill copy({
    int? id,
    String? title,
    double? amount,
    List<RecurringBillTxn>? recurringBillTxns,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      RecurringBill(
        id: id ?? this.id,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        recurringBillTxns: recurringBillTxns ?? this.recurringBillTxns,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  // TODO: implement props
  List<Object?> get props => [
        id,
        title,
        amount,
        recurringBillTxns,
        createdAt,
        updatedAt,
      ];
}
