import 'package:budgetup_app/helper/date_helper.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../helper/constant.dart';
import '../../helper/route_strings.dart';
import '../paywall/paywall.dart';

class SummaryPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final _currentYear = useState(DateTime.now().year);

    //Verify if subscribed
    final isSubscribed = useState(false);
    // final future = useMemoized(() => Purchases.getCustomerInfo());
    // final customerInfo = useFuture(future, initialData: null);
    // useEffect(() {
    //   if (customerInfo.data != null) {
    //     final entitlement =
    //         customerInfo.data!.entitlements.active[entitlementId];
    //     isSubscribed.value = entitlement != null;
    //   } else {
    //     isSubscribed.value = false;
    //   }
    //   return null;
    // }, [customerInfo.data]);

    useEffect(() {
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        final entitlement = customerInfo.entitlements.active[entitlementId];
        isSubscribed.value = entitlement != null;
      });
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: Text("Monthly Statements"),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SvgPicture.asset(
                "assets/icons/ic_arrow_right.svg",
                height: 20.0,
              ),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        _currentYear.value = _currentYear.value - 1;
                      },
                      icon: SvgPicture.asset(
                        "assets/icons/ic_arrow_left.svg",
                      ),
                    ),
                    Text("${_currentYear.value}"),
                    IconButton(
                      onPressed: () {
                        if (_currentYear.value != DateTime.now().year) {
                          _currentYear.value = _currentYear.value + 1;
                        }
                      },
                      icon: SvgPicture.asset(
                        "assets/icons/ic_arrow_right.svg",
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: getPrevMonths(_currentYear.value).length,
                  itemBuilder: (context, index) {
                    final date = getPrevMonths(_currentYear.value)[index];
                    return _summaryItem(
                      context,
                      isSubscribed: isSubscribed.value,
                      date: date,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  showPaywall(BuildContext context) async {
    try {
      final offerings = await Purchases.getOfferings();
      if (context.mounted && offerings.current != null) {
        await showModalBottomSheet(
          isDismissible: true,
          isScrollControlled: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
              return PaywallView(
                offering: offerings.current!,
              );
            });
          },
        );
      }
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Widget _summaryItem(
    BuildContext context, {
    required bool isSubscribed,
    required DateTime date,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () async {
          final customerInfo = await Purchases.getCustomerInfo();
          final hasData =
              customerInfo.entitlements.active[entitlementId] != null;

          if (context.mounted) {
            if (hasData ||
                (getMonthFromDate(date) == getMonthFromDate(DateTime.now()))) {
              Navigator.pushNamed(
                context,
                RouteStrings.summaryDetail,
                arguments: date,
              );
            } else if (getMonthFromDate(date) !=
                getMonthFromDate(DateTime.now())) {
              showPaywall(context);
            }
          }
        },
        child: Material(
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 16,
              cornerSmoothing: 1.0,
            ),
          ),
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              formatDate(
                date,
                "MMMM yyyy",
              ),
            ),
          ),
        ),
      ),
    );
  }
}
