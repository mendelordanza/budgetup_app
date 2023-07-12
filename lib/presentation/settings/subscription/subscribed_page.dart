import 'package:budgetup_app/helper/constant.dart';
import 'package:budgetup_app/helper/date_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscribedPage extends HookWidget {
  const SubscribedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final purchaseDate = useState<String?>(null);
    final renewDate = useState<String?>(null);

    useEffect(() {
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        purchaseDate.value =
            (customerInfo.entitlements.active[entitlementId] as EntitlementInfo)
                .originalPurchaseDate;
        renewDate.value =
            (customerInfo.entitlements.active[entitlementId] as EntitlementInfo)
                .expirationDate;
      });
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SvgPicture.asset(
              "assets/icons/ic_arrow_left.svg",
            ),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "You are a Pro!",
              textAlign: TextAlign.center,
            ),
            SvgPicture.asset("assets/icons/ic_icon_pro.svg"),
            Column(
              children: [
                if (purchaseDate.value != null)
                  Text(
                      "Purchase Date: ${formatDate(DateTime.parse(purchaseDate.value!), "MMMM d, yyyy")}"),
                if (renewDate.value != null)
                  Text("Renew Date: ${renewDate.value}"),
              ],
            )
          ],
        ),
      ),
    );
  }
}
