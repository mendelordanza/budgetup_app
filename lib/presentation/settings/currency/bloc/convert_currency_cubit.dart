import 'package:bloc/bloc.dart';
import 'package:budgetup_app/data/currency_repository.dart';
import 'package:meta/meta.dart';

import '../../../../helper/shared_prefs.dart';

part 'convert_currency_state.dart';

class ConvertCurrencyCubit extends Cubit<ConvertCurrencyState> {
  final CurrencyRepository currencyRepository;
  final SharedPrefs sharedPrefs;

  ConvertCurrencyCubit({
    required this.currencyRepository,
    required this.sharedPrefs,
  }) : super(ConvertCurrencyInitial());

  loadCurrencies() async {
    await currencyRepository.loadCurrencies();
  }

  getCurrencyRate(String currencyCode) async {
    final currencyRate = await currencyRepository.getCurrencyRate(currencyCode);
    emit(ConvertedCurrencyLoaded(currencyCode, currencyRate?.rate ?? 0.00));
  }

  changeCurrency(
    String currencySymbol,
    String currencyCode,
  ) async {
    //Update currencies first
    //await currencyRepository.updateCurrencies("USD");

    //Then load list from DB
    final currencies = await currencyRepository.loadCurrencies();
    final currencyRate =
        currencies.firstWhere((element) => element.country == currencyCode);

    sharedPrefs.setCurrencyRate(currencyRate.rate ?? 0.00);
    sharedPrefs.setCurrencySymbol(currencySymbol);
    sharedPrefs.setCurrencyCode(currencyCode);

    emit(ConvertedCurrencyLoaded(
      currencyCode,
      currencyRate.rate ?? 0.00,
    ));
  }
}
