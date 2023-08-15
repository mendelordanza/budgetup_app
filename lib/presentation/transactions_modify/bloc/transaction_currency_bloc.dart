import 'package:bloc/bloc.dart';
import 'package:budgetup_app/data/currency_repository.dart';
import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:meta/meta.dart';

part 'transaction_currency_event.dart';

part 'transaction_currency_state.dart';

class TransactionCurrencyBloc
    extends Bloc<TransactionCurrencyEvent, TransactionCurrencyState> {
  final SharedPrefs sharedPrefs;
  final CurrencyRepository currencyRepository;
  String currentTxnCurrencyCode = "";
  String currentTxnCurrencySymbol = "";
  double currentTxnCurrencyRate = 0.00;

  TransactionCurrencyBloc({
    required this.sharedPrefs,
    required this.currencyRepository,
  }) : super(TransactionCurrencyInitial()) {
    on<LoadTxnCurrency>((event, emit) async {
      currentTxnCurrencyCode = sharedPrefs.getCurrencyCode();
      currentTxnCurrencySymbol = sharedPrefs.getCurrencySymbol();
      currentTxnCurrencyRate = sharedPrefs.getCurrencyRate();

      //Get Currency Rate
      final currencies = await currencyRepository.loadCurrencies();
      currentTxnCurrencyRate = currencies
              .singleWhere((e) => e.country == currentTxnCurrencyCode)
              .rate ??
          0.00;
      emit(TxnCurrencyLoaded(
        currentTxnCurrencyCode,
        currentTxnCurrencySymbol,
        currentTxnCurrencyRate,
      ));
    });
    on<SelectTxnCurrency>((event, emit) async {
      emit(LoadingTxnCurrency());

      if (event.currencyCode == sharedPrefs.getCurrencyCode()) {
        currentTxnCurrencyCode = sharedPrefs.getCurrencyCode();
        currentTxnCurrencySymbol = sharedPrefs.getCurrencySymbol();
        currentTxnCurrencyRate = sharedPrefs.getCurrencyRate();
      } else {
        currentTxnCurrencyCode = event.currencyCode;
        currentTxnCurrencySymbol = event.currencySymbol;

        //Get Currency
        final currencies = await currencyRepository.callExchangeRateApi();
        currentTxnCurrencyRate = currencies
                .singleWhere((e) => e.country == currentTxnCurrencyCode)
                .rate ??
            0.00;
      }

      emit(TxnCurrencyLoaded(
        currentTxnCurrencyCode,
        currentTxnCurrencySymbol,
        currentTxnCurrencyRate,
      ));
    });
  }
}
