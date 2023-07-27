import 'package:budgetup_app/data/local/entities/salary_entity.dart';
import 'package:isar/isar.dart';

class Salary {
  final int? id;
  final double? amount;
  final int? month;
  final int? year;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Salary({
    this.id,
    this.amount,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
  });

  SalaryEntity toIsar() {
    final isarObject = SalaryEntity()
      ..id = id != null ? id! : Isar.autoIncrement
      ..amount = amount
      ..month = month
      ..year = year
      ..createdAt = createdAt
      ..updatedAt = updatedAt;
    return isarObject;
  }

  factory Salary.fromJson(Map<dynamic, dynamic> json) => Salary(
        id: json["id"],
        amount: json["amount"],
        month: json["month"],
        year: json["year"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "amount": amount,
        "month": month,
        "year": year,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };

  Salary copy({
    int? id,
    double? amount,
    int? month,
    int? year,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Salary(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        month: month ?? this.month,
        year: year ?? this.year,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
