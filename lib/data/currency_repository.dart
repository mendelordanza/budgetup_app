import 'package:budgetup_app/data/http_service.dart';
import 'package:budgetup_app/data/local/entities/currency_rate_entity.dart';
import 'package:budgetup_app/data/local/isar_service.dart';

class CurrencyRepository {
  final HttpService httpService;
  final IsarService isarService;

  const CurrencyRepository({
    required this.httpService,
    required this.isarService,
  });

  Future<List<CurrencyRateEntity>> loadCurrencies() async {
    final savedCurrencies = await isarService.getAllCurrencies();

    List<CurrencyRateEntity> currencies = [];
    if (savedCurrencies.isEmpty) {
      final currencyData =
          await httpService.getCurrencies(baseCurrencyCode: "USD");
      currencies = currencyData.conversionRates.entries.map((entry) {
        final currencyEntity = CurrencyRateEntity()
          ..country = entry.key
          ..rate = double.parse(entry.value.toString());
        isarService.addCurrency(currencyEntity);
        return currencyEntity;
      }).toList();
    } else {
      currencies = savedCurrencies;
    }

    return currencies;
  }

  Future<void> updateCurrencies(String baseCurrencyCode) async {
    await isarService.deleteAllCurrencies();

    final data =
        await httpService.getCurrencies(baseCurrencyCode: baseCurrencyCode);
    data.conversionRates.forEach((key, value) {
      final currencyEntity = CurrencyRateEntity()
        ..country = key
        ..rate = double.parse(value.toString());
      isarService.addCurrency(currencyEntity);
    });
  }

  Future<CurrencyRateEntity?> getCurrencyRate(String currencyCode) async {
    final data = await isarService.getCurrencyRate(currencyCode);
    return data;
  }
}
