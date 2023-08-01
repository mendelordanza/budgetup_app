import 'package:isar/isar.dart';

part 'salary_entity.g.dart';

@collection
class SalaryEntity {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment

  double? amount;
  int? month;
  int? year;
  DateTime? createdAt;
  DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'month': month,
      'year': year,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
