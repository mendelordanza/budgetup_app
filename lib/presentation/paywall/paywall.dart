import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../helper/colors.dart';
import '../custom/custom_button.dart';
import '../custom/platform_progress_indicator.dart';
import 'package:collection/collection.dart';

class PaywallView extends HookWidget {
  final bool isFromOnboarding;
  final Offering offering;

  PaywallView({this.isFromOnboarding = false, required this.offering});

  restorePurchase(BuildContext context) async {
    try {
      await Purchases.restorePurchases().then((value) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("You are now a Pro!")));
        Navigator.pop(context);
      }).onError((error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No previous purchase found.")));
      });
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? "Error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    //final selectedProduct = useState<StoreProduct?>(null);
    final selectedIndex = useState(-1);
    final isLoading = useState(false);

    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          24.0,
          16.0,
          24.0,
          0.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.close),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                      children: [
                        Text(
                          "Unlock more with",
                        ),
                        Text(
                          "BudgetUp Pro",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          Column(
                            children: offering.availablePackages
                                .mapIndexed((index, item) {
                              return priceItem(
                                context,
                                item: item,
                                isSelected: index == selectedIndex.value,
                                onTap: () {
                                  selectedIndex.value = index;
                                  //selectedProduct.value = item.storeProduct;
                                },
                              );
                            }).toList(),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              isLoading.value = true;
                              restorePurchase(context);
                              isLoading.value = false;
                            },
                            child: Text(
                              "Already Subscribed? Restore Purchase",
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          featureItem(
                            icon: Icon(Iconsax.money_send),
                            title: "Unlimited Expense Categories",
                            desc: "track your expenses without limits",
                          ),
                          featureItem(
                            icon: SvgPicture.asset(
                              "assets/icons/ic_recurring.svg",
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            title: "Unlimited Recurring Bills",
                            desc: "track your recurring bills without limits",
                          ),
                          featureItem(
                            icon: SvgPicture.asset(
                              "assets/icons/ic_calendar.svg",
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            title: "Previous Monthly Statements",
                            desc: "see the breakdown of your finances",
                          ),
                          featureItem(
                            icon: Icon(Iconsax.home_hashtag),
                            title: "Home Screen Widget",
                            desc:
                                "get a glance of your finances in your home screen",
                          ),
                          featureItem(
                            icon: Icon(Iconsax.back_square),
                            title: "Data Backup",
                            desc:
                                "import and export data to continue using on other device",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: isFromOnboarding ? 0.0 : 24.0),
              child: CustomButton(
                onPressed: () async {
                  isLoading.value = true;
                  if (selectedIndex.value != -1) {
                    final item = offering
                        .availablePackages[selectedIndex.value].storeProduct;
                    await Purchases.purchaseStoreProduct(item).then((value) {
                      isLoading.value = false;
                      Navigator.pop(context);
                    }).onError((error, stackTrace) {
                      isLoading.value = false;
                    });
                  } else {
                    isLoading.value = false;
                  }
                },
                color: selectedIndex.value == -1
                    ? Colors.grey.shade400
                    : primaryColor,
                child: isLoading.value
                    ? Center(child: PlatformProgressIndicator())
                    : Text(
                        selectedIndex.value == -1
                            ? "Buy"
                            : "Buy ${offering.availablePackages[selectedIndex.value].storeProduct.title.replaceAll(RegExp('\\(.*?\\)'), '')}",
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
            if (isFromOnboarding)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("I'll do it later"),
              )
          ],
        ),
      ),
    );
  }

  Widget featureItem({
    required Widget icon,
    required String title,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon,
          SizedBox(
            width: 13.0,
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13.0,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget priceItem(
    BuildContext context, {
    required Package item,
    required bool isSelected,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Material(
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 16,
              cornerSmoothing: 1.0,
            ),
            side: isSelected
                ? BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2.0,
                  )
                : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    // Checkbox(
                    //   activeColor: secondaryColor,
                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(
                    //       3.0,
                    //     ),
                    //   ),
                    //   value: isSelected,
                    //   onChanged: (checked) {
                    //     onTap();
                    //   },
                    // ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            item.storeProduct.title
                                .replaceAll(RegExp('\\(.*?\\)'), ''),
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            item.storeProduct.description,
                            style: TextStyle(
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      item.storeProduct.priceString,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
