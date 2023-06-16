import 'package:budgetup_app/domain/currency_data.dart';
import 'package:dio/dio.dart';

class HttpService {
  static Dio dio = Dio();

  Future<CurrencyData> getCurrencies({required String baseCurrencyCode}) async {
    try {
      final url =
          "https://v6.exchangerate-api.com/v6/a8351699c2490236ba5c77bb/latest/$baseCurrencyCode";
      final response = await dio.get(url);
      final currencyData = CurrencyData.fromJson(response.data);
      return currencyData;
    } catch (e) {
      print(e);
      return Future.error("Something went wrong.");
    }
  }
}
