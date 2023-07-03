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

  Map<String, Object?> toJson() => {
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
