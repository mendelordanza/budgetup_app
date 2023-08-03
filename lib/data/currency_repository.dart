import 'package:budgetup_app/data/http_service.dart';
import 'package:budgetup_app/data/local/entities/currency_rate_entity.dart';
import 'package:budgetup_app/data/local/isar_service.dart';
import 'package:budgetup_app/helper/date_helper.dart';
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
    final lastUpdateDate = sharedPrefs.getCurrencyUpdateDate();

    if (savedCurrencies.isEmpty || lastUpdateDate == null) {
      return true;
    }

    final now = removeTimeFromDate(DateTime.now());
    final timeToUpdate = removeTimeFromDate(DateTime.parse(lastUpdateDate));

    return now.isAfter(timeToUpdate) || now.isAtSameMomentAs(timeToUpdate);
  }

  Future<List<CurrencyRateEntity>> getSavedCurrencies() async {
    return await isarService.getAllCurrencies();
  }

  Future<List<CurrencyRateEntity>> callExchangeRateApi() async {
    final currencyData =
        await httpService.getCurrencies(baseCurrencyCode: "USD");

    //DELETE ALL
    isarService.deleteAllCurrencies();

    final currencies = currencyData.conversionRates.entries.map((entry) {
      final currencyEntity = CurrencyRateEntity()
        ..country = entry.key
        ..rate = double.parse(entry.value.toString());
      isarService.addCurrency(currencyEntity);
      return currencyEntity;
    }).toList();

    final currency = currencies.firstWhere(
        (element) => element.country == sharedPrefs.getCurrencyCode());

    sharedPrefs.setCurrencyRate(currency.rate ?? 0.00);
    sharedPrefs.setCurrencyUpdateDate(currencyData.timeNextUpdate);

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
