class CurrencyData {
  final String baseCode;
  final Map<String, dynamic> conversionRates;

  CurrencyData({
    required this.baseCode,
    required this.conversionRates,
  });

  factory CurrencyData.fromJson(Map<dynamic, dynamic> json) => CurrencyData(
        baseCode: json["base_code"],
        conversionRates: json["conversion_rates"],
      );

  Map<String, dynamic> toJson() => {
        "base_code": baseCode,
        "conversion_rates": conversionRates,
      };
}
