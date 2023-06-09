import 'package:budgetup_app/domain/recurring_bill_txn.dart';
import 'package:equatable/equatable.dart';

class RecurringBill extends Equatable {
  final int? id;
  final String? title;
  final double? amount;
  final DateTime? reminderDate;
  final List<RecurringBillTxn>? recurringBillTxns;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RecurringBill({
    this.id,
    this.title,
    this.amount,
    this.reminderDate,
    this.recurringBillTxns,
    this.createdAt,
    this.updatedAt,
  });

  isPaid(DateTime selectedDate) {
    final paid = recurringBillTxns?.where((element) {
      return element.datePaid!.month == selectedDate.month;
    }).toList();
    return paid?.isNotEmpty;
  }

  factory RecurringBill.fromJson(Map<dynamic, dynamic> json) => RecurringBill(
        id: json["id"],
        title: json["title"],
        amount: json["amount"],
        reminderDate: json["reminderDate"],
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
    DateTime? reminderDate,
    List<RecurringBillTxn>? recurringBillTxns,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      RecurringBill(
        id: id ?? this.id,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        reminderDate: reminderDate ?? this.reminderDate,
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
        reminderDate,
        recurringBillTxns,
        createdAt,
        updatedAt,
      ];
}
