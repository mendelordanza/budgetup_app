import 'package:isar/isar.dart';

part 'currency_rate_entity.g.dart';

@collection
class CurrencyRateEntity {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment

  String? country;
  double? rate;
}
