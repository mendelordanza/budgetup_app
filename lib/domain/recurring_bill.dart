import 'package:budgetup_app/data/local/entities/recurring_bill_txn_entity.dart';
import 'package:budgetup_app/domain/recurring_bill_txn.dart';
import 'package:budgetup_app/helper/date_helper.dart';
import 'package:budgetup_app/helper/string.dart';
import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

import '../data/local/entities/recurring_bill_entity.dart';

class RecurringBill extends Equatable {
  final int? id;
  final String? title;
  final double? amount;
  final String? interval;
  final DateTime? reminderDate;
  final List<RecurringBillTxn>? recurringBillTxns;
  final bool? archived;
  final DateTime? archivedDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RecurringBill({
    this.id,
    this.title,
    this.amount,
    this.interval,
    this.reminderDate,
    this.recurringBillTxns,
    this.archived,
    this.archivedDate,
    this.createdAt,
    this.updatedAt,
  });

  isPaid(DateTime selectedDate) {
    final paid = recurringBillTxns?.where((element) {
      return getMonthFromDate(element.datePaid!) ==
          getMonthFromDate(selectedDate);
    }).toList();
    return paid?.isNotEmpty;
  }

  factory RecurringBill.fromJson(Map<dynamic, dynamic> json) => RecurringBill(
        id: json["id"],
        title: json["title"],
        amount: json["amount"],
        interval: json["interval"],
        reminderDate: json["reminderDate"],
        recurringBillTxns: List<RecurringBillTxn>.from(json["recurringBillTxns"]
            .map((txn) => RecurringBillTxn.fromJson(
                (txn as RecurringBillTxnEntity).toJson()))),
        archived: json["archived"],
        archivedDate: json["archivedDate"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
      );

  factory RecurringBill.fromJsonFile(Map<dynamic, dynamic> json) {
    return RecurringBill(
      id: json["id"],
      title: json["title"],
      amount: double.parse(removeFormatting(json["amount"].toString())),
      interval: json["interval"],
      reminderDate: DateTime.parse(json["reminderDate"]),
      recurringBillTxns: List<RecurringBillTxn>.from(json["recurringBillTxns"]
          .map((txn) => RecurringBillTxn.fromJsonFile(txn))),
      archived: json["archived"],
      archivedDate: json["archivedDate"] == null
          ? null
          : DateTime.parse(json["archivedDate"]),
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "amount": decimalFormatterWithSymbol(amount ?? 0.00),
        "interval": interval,
        "recurringBillTxns": recurringBillTxns?.map((e) => e.toJson()).toList(),
        "reminderDate": reminderDate?.toIso8601String(),
        "archived": archived,
        "archiveDate": archivedDate?.toIso8601String(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };

  RecurringBillEntity toIsar() {
    return RecurringBillEntity()
      ..id = id != null ? id! : Isar.autoIncrement
      ..title = title
      ..amount = amount
      ..interval = interval
      ..reminderDate = reminderDate
      ..archived = archived
      ..archivedDate = archivedDate
      ..createdAt = createdAt
      ..updatedAt = updatedAt;
  }

  RecurringBill copy({
    int? id,
    String? title,
    double? amount,
    String? interval,
    DateTime? reminderDate,
    List<RecurringBillTxn>? recurringBillTxns,
    bool? archived,
    DateTime? archivedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      RecurringBill(
        id: id ?? this.id,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        interval: interval ?? this.interval,
        reminderDate: reminderDate ?? this.reminderDate,
        recurringBillTxns: recurringBillTxns ?? this.recurringBillTxns,
        archived: archived ?? this.archived,
        archivedDate: archivedDate ?? this.archivedDate,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  // TODO: implement props
  List<Object?> get props => [
        id,
        title,
        amount,
        interval,
        reminderDate,
        recurringBillTxns,
        archived,
        archivedDate,
        createdAt,
        updatedAt,
      ];
}
