import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:purchases_flutter/models/offering_wrapper.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../helper/colors.dart';
import '../custom/custom_button.dart';

class PaywallView extends HookWidget {
  final Offering offering;

  PaywallView({required this.offering});

  @override
  Widget build(BuildContext context) {
    final selectedProduct = useState<StoreProduct?>(null);
    final isLoading = useState(false);

    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
                    SvgPicture.asset(
                      "assets/icons/ic_icon_pro.svg",
                    ),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: offering.availablePackages.length,
                      itemBuilder: (context, index) {
                        final item = offering.availablePackages[index];
                        return priceItem(
                          item: item,
                          isSelected: item.storeProduct.identifier ==
                              selectedProduct.value?.identifier,
                          onTap: () {
                            selectedProduct.value = item.storeProduct;
                          },
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          featureItem(
                            title: "Unlimited Lists",
                            desc:
                                "unlimited expense categories and recurring bills",
                          ),
                          featureItem(
                            title: "Summary Report",
                            desc: "summary report at the end of every month",
                          ),
                          featureItem(
                            title: "Data Backup - coming soon!",
                            desc:
                                "import and export data to continue using on other device",
                          ),
                          featureItem(
                            title: "Home Screen Widget - coming soon!",
                            desc:
                                "overview of your total expense in your home screen",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            CustomButton(
              onPressed: () async {
                isLoading.value = true;
                if (selectedProduct.value != null) {
                  await Purchases.purchaseStoreProduct(selectedProduct.value!)
                      .then((value) {
                    isLoading.value = false;
                  }).onError((error, stackTrace) {
                    isLoading.value = false;
                  });
                } else {
                  isLoading.value = false;
                }
              },
              color: selectedProduct.value == null ? dark : primaryColor,
              child: isLoading.value
                  ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text(
                      "Buy ${selectedProduct.value?.title ?? ""}",
                      textAlign: TextAlign.center,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget featureItem({
    required String title,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Iconsax.document_text),
          SizedBox(
            width: 13.0,
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                ),
                SizedBox(
                  height: 6.0,
                ),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget priceItem({
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
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              0.0,
              16.0,
              16.0,
              16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Checkbox(
                      activeColor: secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          3.0,
                        ),
                      ),
                      value: isSelected,
                      onChanged: (checked) {
                        onTap();
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            item.storeProduct.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
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
