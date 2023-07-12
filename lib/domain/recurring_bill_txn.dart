import 'package:budgetup_app/data/local/entities/recurring_bill_txn_entity.dart';
import 'package:budgetup_app/domain/recurring_bill.dart';
import 'package:equatable/equatable.dart';

class RecurringBillTxn extends Equatable {
  final int? id;
  final bool isPaid;
  final DateTime? datePaid;

  RecurringBillTxn({
    this.id,
    required this.isPaid,
    this.datePaid,
  });

  factory RecurringBillTxn.fromJson(Map<dynamic, dynamic> json) =>
      RecurringBillTxn(
        id: json["id"],
        isPaid: json["isPaid"],
        datePaid: json["datePaid"],
      );

  factory RecurringBillTxn.fromJsonFile(Map<dynamic, dynamic> json) =>
      RecurringBillTxn(
        id: json["id"],
        isPaid: json["isPaid"],
        datePaid: DateTime.parse(json["datePaid"]),
      );

  RecurringBillTxnEntity toIsar({required RecurringBill bill}) {
    return RecurringBillTxnEntity()
      ..id = id!
      ..recurringBill.value = bill.toIsar()
      ..isPaid = isPaid
      ..datePaid = datePaid;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "isPaid": isPaid,
        "datePaid": datePaid?.toIso8601String(),
      };

  RecurringBillTxn copy({
    int? id,
    bool? isPaid,
    DateTime? datePaid,
    RecurringBill? recurringBill,
  }) =>
      RecurringBillTxn(
        id: id ?? this.id,
        isPaid: isPaid ?? this.isPaid,
        datePaid: datePaid ?? this.datePaid,
      );

  @override
  // TODO: implement props
  List<Object?> get props => [
        id,
        isPaid,
        datePaid,
      ];
}
