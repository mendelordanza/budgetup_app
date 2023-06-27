import 'package:budgetup_app/helper/route_strings.dart';
import 'package:budgetup_app/presentation/paywall/paywall.dart';
import 'package:budgetup_app/presentation/settings/currency/bloc/convert_currency_cubit.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helper/constant.dart';

class SettingsPage extends HookWidget {
  SettingsPage({super.key});

  _launchUrl(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  _launchEmail(String email) async {
    if (!await launchUrl(Uri.parse("mailto:$email"))) {
      throw Exception('Could not launch mailto:$email');
    }
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

  restorePurchase(BuildContext context) async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      print(customerInfo.entitlements.active);
      if (customerInfo.entitlements.active[entitlementId] != null) {
        //TODO set entitlement
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("No previous purchase")));
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? "Error")));
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text("Settings"),
        centerTitle: true,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SettingsContainer(
                        padding: EdgeInsets.zero,
                        settingItems: [
                          SettingItem(
                            onTap: () async {
                              final customerInfo =
                                  await Purchases.getCustomerInfo();
                              if (customerInfo
                                      .entitlements.active[entitlementId] !=
                                  null) {
                                isSubscribed.value = true;
                              } else if (context.mounted) {
                                showPaywall(context);
                              }
                            },
                            icon: "assets/icons/ic_app_icon.svg",
                            iconBackgroundColor: Color(0xFF666666),
                            label: isSubscribed.value
                                ? "You are subscribed to BudegetUp Pro!"
                                : "Unlock BudgetUp Pro",
                            subtitle: isSubscribed.value
                                ? null
                                : "Enjoy all features!",
                            suffix: SvgPicture.asset(
                              "assets/icons/ic_arrow_right.svg",
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          restorePurchase(context);
                        },
                        child: Text("Restore Purchase"),
                      ),
                      SettingsContainer(
                        label: "App",
                        settingItems: [
                          SettingItem(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, RouteStrings.appearance);
                            },
                            icon: "assets/icons/ic_moon.svg",
                            iconBackgroundColor: Color(0xFF9300ED),
                            label: "Appearance",
                            suffix: SvgPicture.asset(
                              "assets/icons/ic_arrow_right.svg",
                            ),
                          ),
                          Divider(),
                          SettingItem(
                            onTap: () {
                              showCurrencyPicker(
                                context: context,
                                showFlag: true,
                                showCurrencyName: true,
                                showCurrencyCode: true,
                                onSelect: (Currency currency) {
                                  context
                                      .read<ConvertCurrencyCubit>()
                                      .changeCurrency(
                                          currency.symbol, currency.code);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Curreny updated to ${currency.code}")));
                                },
                              );
                            },
                            icon: "assets/icons/ic_currency.svg",
                            iconBackgroundColor: Color(0xFF00A61B),
                            label: "Currency",
                            suffix: SvgPicture.asset(
                              "assets/icons/ic_arrow_right.svg",
                            ),
                          ),
                          Divider(),
                          SettingItem(
                            onTap: () {},
                            icon: "assets/icons/ic_import_export.svg",
                            iconBackgroundColor: Color(0xFFC26900),
                            label: "Import / Export Data - Coming Soon!",
                            suffix: SvgPicture.asset(
                              "assets/icons/ic_arrow_right.svg",
                            ),
                          ),
                          Divider(),
                          SettingItem(
                            onTap: () {},
                            icon: "assets/icons/ic_widget.svg",
                            iconBackgroundColor: Color(0xFF00b2c2),
                            label: "Home Screen Widget - Coming Soon!",
                            suffix: SvgPicture.asset(
                              "assets/icons/ic_arrow_right.svg",
                            ),
                          ),
                        ],
                      ),
                      SettingsContainer(
                        label: "General",
                        settingItems: [
                          SettingItem(
                            onTap: () async {
                              final InAppReview inAppReview =
                                  InAppReview.instance;
                              if (await inAppReview.isAvailable()) {
                                inAppReview.requestReview();
                              }
                            },
                            icon: "assets/icons/ic_star.svg",
                            iconBackgroundColor: Color(0xFFFFC700),
                            label: "Rate the app",
                            suffix: SvgPicture.asset(
                              "assets/icons/ic_arrow_right.svg",
                            ),
                          ),
                          Divider(),
                          SettingItem(
                            onTap: () {},
                            icon: "assets/icons/ic_share.svg",
                            iconBackgroundColor: Color(0xFFB43D3D),
                            label: "Share the app",
                            suffix: SvgPicture.asset(
                              "assets/icons/ic_arrow_right.svg",
                            ),
                          ),
                          Divider(),
                          SettingItem(
                            onTap: () {
                              _launchUrl("https://forms.gle/M5qmLiT2FSLXAz8Y7");
                            },
                            icon: "assets/icons/ic_send.svg",
                            iconBackgroundColor: Color(0xFF0069B6),
                            label: "Send feedback",
                            suffix: SvgPicture.asset(
                              "assets/icons/ic_arrow_right.svg",
                            ),
                          ),
                          Divider(),
                          SettingItem(
                            onTap: () {
                              _launchEmail("mendelordanza@gmail.com");
                            },
                            icon: "assets/icons/ic_contact.svg",
                            iconBackgroundColor: Color(0xFFff9cf5),
                            label: "Contact",
                            suffix: SvgPicture.asset(
                              "assets/icons/ic_arrow_right.svg",
                            ),
                          ),
                          Divider(),
                          SettingItem(
                            onTap: () {
                              Navigator.pushNamed(context, RouteStrings.debug);
                            },
                            icon: "assets/icons/ic_code.svg",
                            iconBackgroundColor: Color(0xFF03adfc),
                            label: "Debug",
                            suffix: SvgPicture.asset(
                              "assets/icons/ic_arrow_right.svg",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                "BudgetUp v1.0",
                style: TextStyle(fontSize: 12.0),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SettingsContainer extends StatelessWidget {
  final String? label;
  final List<Widget> settingItems;
  final EdgeInsetsGeometry padding;

  SettingsContainer({
    this.label,
    required this.settingItems,
    this.padding = const EdgeInsets.only(
      bottom: 16.0,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (label != null)
            Text(
              label!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          SizedBox(
            height: 10,
          ),
          Material(
            color: Theme.of(context).cardColor,
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 16,
                cornerSmoothing: 1.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: settingItems,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class SettingItem extends StatelessWidget {
  final Function() onTap;
  final String? icon;
  final String? iconSize;
  final Color? iconBackgroundColor;
  final String label;
  final String? subtitle;
  final Widget? suffix;

  SettingItem({
    required this.onTap,
    this.icon,
    this.iconSize,
    this.iconBackgroundColor,
    required this.label,
    this.subtitle,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            if (icon != null && iconBackgroundColor != null)
              Container(
                height: 30.0,
                width: 30.0,
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: SvgPicture.asset(
                  icon!,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: iconBackgroundColor,
                ),
              ),
            SizedBox(
              width: 10.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    label,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                ],
              ),
            ),
            if (suffix != null) suffix!,
          ],
        ),
      ),
    );
  }
}
