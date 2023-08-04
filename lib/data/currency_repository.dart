import 'package:budgetup_app/data/http_service.dart';
import 'package:budgetup_app/data/local/entities/currency_rate_entity.dart';
import 'package:budgetup_app/data/local/isar_service.dart';
import 'package:budgetup_app/helper/shared_prefs.dart';

class CurrencyRepository {
  final HttpService httpService;
  final IsarService isarService;
  final SharedPrefs sharedPrefs;

  const CurrencyRepository({
    required this.httpService,
    required this.isarService,
    required this.sharedPrefs,
  });

  Future<List<CurrencyRateEntity>> loadCurrencies() async {
    List<CurrencyRateEntity> currencies = [];
    if (await shouldUpdateCurrencies()) {
      try {
        currencies = await callExchangeRateApi();
        saveToDB(currencies: currencies);
      } catch (e) {
        // Handle any error occurred during API call or saving currencies
        print("Error updating currencies: $e");
      }
    } else {
      currencies = await getSavedCurrencies();
    }

    return currencies;
  }

  Future<bool> shouldUpdateCurrencies() async {
    final savedCurrencies = await getSavedCurrencies();
    if (savedCurrencies.isEmpty) {
      return true;
    }
    return false;
  }

  Future<List<CurrencyRateEntity>> getSavedCurrencies() async {
    return await isarService.getAllCurrencies();
  }

  Future<List<CurrencyRateEntity>> callExchangeRateApi() async {
    final currencyData =
        await httpService.getCurrencies(baseCurrencyCode: "USD");

    return currencyData.conversionRates.entries.map((entry) {
      final currencyEntity = CurrencyRateEntity()
        ..country = entry.key
        ..rate = double.parse(entry.value.toString());
      return currencyEntity;
    }).toList();
  }

  Future<void> saveToDB({required List<CurrencyRateEntity> currencies}) async {
    //DELETE ALL
    isarService.deleteAllCurrencies();

    currencies.forEach((entry) {
      final currencyEntity = CurrencyRateEntity()
        ..country = entry.country
        ..rate = double.parse(entry.rate.toString());
      isarService.addCurrency(currencyEntity);
    });
  }

  Future<CurrencyRateEntity?> getCurrencyRate(String currencyCode) async {
    final data = await isarService.getCurrencyRate(currencyCode);
    return data;
  }
}
