import 'package:budgetup_app/helper/shared_prefs.dart';

import '../injection_container.dart';

convertToCurrency(double amount) {
  final sharedPrefs = getIt<SharedPrefs>();
  return sharedPrefs.getCurrencyCode() == "USD"
      ? amount
      : amount * sharedPrefs.getCurrencyRate();
}
