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
    return savedCurrencies;
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
