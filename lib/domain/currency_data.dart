import 'package:intl/intl.dart';

class CurrencyData {
  final String baseCode;
  final Map<String, dynamic> conversionRates;
  final String timeNextUpdate;

  CurrencyData({
    required this.baseCode,
    required this.conversionRates,
    required this.timeNextUpdate,
  });

  factory CurrencyData.fromJson(Map<dynamic, dynamic> json) => CurrencyData(
        baseCode: json["base_code"],
        conversionRates: json["conversion_rates"],
        timeNextUpdate: DateFormat("E, d MMM yyyy HH:mm:ss Z")
            .parseUtc(json["time_next_update_utc"])
            .toIso8601String(),
      );

  Map<String, dynamic> toJson() => {
        "base_code": baseCode,
        "conversion_rates": conversionRates,
        "timeNextUpdate": timeNextUpdate,
      };
}
