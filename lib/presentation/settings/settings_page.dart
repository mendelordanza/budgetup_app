import 'package:budgetup_app/helper/route_strings.dart';
import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:budgetup_app/injection_container.dart';
import 'package:budgetup_app/presentation/paywall/paywall.dart';
import 'package:budgetup_app/presentation/settings/currency/bloc/convert_currency_cubit.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
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

  Future<String> getVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  Future<String> getPackageName() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.packageName;
  }

  @override
  Widget build(BuildContext context) {
    final sharedPrefs = getIt<SharedPrefs>();

    final isSubscribed = useState(false);

    final currentVersion = useState("");
    final future = useMemoized(() => getVersion());
    final version = useFuture(future, initialData: "");
    useEffect(() {
      if (version.data != null) {
        currentVersion.value = version.data!;
      }
      return null;
    }, [version.data]);

    final currentPackageName = useState("com.ralphordanza.budgetupapp");
    final futurePackageName = useMemoized(() => getPackageName());
    final packageName = useFuture(futurePackageName, initialData: "");
    useEffect(() {
      if (packageName.data != null) {
        currentPackageName.value = packageName.data!;
      }
      return null;
    }, [packageName.data]);

    useEffect(() {
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        final entitlement = customerInfo.entitlements.active[entitlementId];
        isSubscribed.value =
            entitlement != null && entitlement.isSandbox == false;
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
                        padding: EdgeInsets.only(
                          bottom: 16.0,
                        ),
                        settingItems: [
                          SettingItem(
                            onTap: () async {
                              final customerInfo =
                                  await Purchases.getCustomerInfo();
                              if (customerInfo
                                          .entitlements.active[entitlementId] !=
                                      null &&
                                  customerInfo.entitlements
                                          .active[entitlementId]!.isSandbox ==
                                      false) {
                                isSubscribed.value = true;
                                if (context.mounted) {
                                  Navigator.pushNamed(
                                      context, RouteStrings.subStatus);
                                }
                              } else if (context.mounted) {
                                showPaywall(context);
                              }
                            },
                            icon: SvgPicture.asset(
                                "assets/icons/ic_app_icon.svg"),
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
                      SettingsContainer(
                        label: "App",
                        settingItems: [
                          SettingItem(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, RouteStrings.appearance);
                            },
                            icon: SvgPicture.asset("assets/icons/ic_moon.svg"),
                            iconBackgroundColor: Color(0xFF9300ED),
                            label: "Appearance",
                            suffix: SvgPicture.asset(
                              "assets/icons/ic_arrow_right.svg",
                            ),
                          ),
                          Divider(),
                          BlocBuilder<ConvertCurrencyCubit,
                              ConvertCurrencyState>(
                            builder: (context, state) {
                              if (state is ConvertedCurrencyLoaded) {
                                return SettingItem(
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
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    "Currency updated to ${currency.code}")));
                                      },
                                    );
                                  },
                                  icon: SvgPicture.asset(
                                      "assets/icons/ic_currency.svg"),
                                  iconBackgroundColor: const Color(0xFF00A61B),
                                  label: "Currency",
                                  subtitle: state.currencyCode,
                                  suffix: SvgPicture.asset(
                                    "assets/icons/ic_arrow_right.svg",
                                  ),
                                );
                              }
                              return SettingItem(
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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  "Currency updated to ${currency.code}")));
                                    },
                                  );
                                },
                                icon: SvgPicture.asset(
                                    "assets/icons/ic_currency.svg"),
                                iconBackgroundColor: const Color(0xFF00A61B),
                                label: "Currency",
                                subtitle: sharedPrefs.getCurrencyCode(),
                                suffix: SvgPicture.asset(
                                  "assets/icons/ic_arrow_right.svg",
                                ),
                              );
                            },
                          ),
                          Divider(),
                          // SettingItem(
                          //   onTap: () {},
                          //   icon:
                          //       SvgPicture.asset("assets/icons/ic_archive.svg"),
                          //   iconBackgroundColor: Color(0xFFff3030),
                          //   label: "Archived Bills",
                          //   suffix: SvgPicture.asset(
                          //     "assets/icons/ic_arrow_right.svg",
                          //   ),
                          // ),
                          // Divider(),
                          SettingItem(
                            onTap: () {
                              Navigator.pushNamed(context, RouteStrings.widget);
                            },
                            icon:
                                SvgPicture.asset("assets/icons/ic_widget.svg"),
                            iconBackgroundColor: Color(0xFF00b2c2),
                            label: "Home Screen Widget",
                            suffix: SvgPicture.asset(
                              "assets/icons/ic_arrow_right.svg",
                            ),
                          ),
                          Divider(),
                          SettingItem(
                            onTap: () {
                              Navigator.pushNamed(context, RouteStrings.backup);
                            },
                            icon: SvgPicture.asset(
                                "assets/icons/ic_import_export.svg"),
                            iconBackgroundColor: Color(0xFFC26900),
                            label: "Import / Export Data",
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
                              inAppReview.openStoreListing(
                                appStoreId: currentPackageName.value,
                              );
                            },
                            icon: SvgPicture.asset("assets/icons/ic_star.svg"),
                            iconBackgroundColor: Color(0xFFFFC700),
                            label: "Rate the app",
                            suffix: SvgPicture.asset(
                              "assets/icons/ic_arrow_right.svg",
                            ),
                          ),
                          // Divider(),
                          // SettingItem(
                          //   onTap: () {},
                          //   icon: "assets/icons/ic_share.svg",
                          //   iconBackgroundColor: Color(0xFFB43D3D),
                          //   label: "Share the app",
                          //   suffix: SvgPicture.asset(
                          //     "assets/icons/ic_arrow_right.svg",
                          //   ),
                          // ),
                          //Divider(),
                          // SettingItem(
                          //   onTap: () {
                          //     _launchUrl("https://forms.gle/M5qmLiT2FSLXAz8Y7");
                          //   },
                          //   icon: SvgPicture.asset("assets/icons/ic_send.svg"),
                          //   iconBackgroundColor: Color(0xFF0069B6),
                          //   label: "Send feedback",
                          //   suffix: SvgPicture.asset(
                          //     "assets/icons/ic_arrow_right.svg",
                          //   ),
                          // ),
                          Divider(),
                          SettingItem(
                            onTap: () {
                              //TODO open about page
                              Navigator.pushNamed(
                                  context, RouteStrings.contact);
                            },
                            icon:
                                SvgPicture.asset("assets/icons/ic_contact.svg"),
                            iconBackgroundColor: Color(0xFFff9cf5),
                            label: "Contact",
                            suffix: SvgPicture.asset(
                              "assets/icons/ic_arrow_right.svg",
                            ),
                          ),
                          Divider(),
                          SettingItem(
                            onTap: () {
                              _launchUrl(
                                  "https://budgetup.notion.site/BudgetUp-Terms-of-Service-0f0bf474649646eb94f39d562cf9d366?pvs=4");
                            },
                            icon: const Center(
                              child: Icon(
                                Iconsax.book,
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                            iconBackgroundColor: Color(0xFFff7a7a),
                            label: "Terms of Service",
                            suffix: SvgPicture.asset(
                              "assets/icons/ic_arrow_right.svg",
                            ),
                          ),
                          Divider(),
                          SettingItem(
                            onTap: () {
                              _launchUrl(
                                  "https://budgetup.notion.site/BudgetUp-Privacy-Policy-e3cf48a7d2ba4661be89963696363918?pvs=4");
                            },
                            icon: const Center(
                              child: Icon(
                                Iconsax.security,
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                            iconBackgroundColor: Color(0xFF42a68a),
                            label: "Privacy Policy",
                            suffix: SvgPicture.asset(
                              "assets/icons/ic_arrow_right.svg",
                            ),
                          ),
                          Divider(),
                          SettingItem(
                            onTap: () {
                              Navigator.pushNamed(context, RouteStrings.debug);
                            },
                            icon: SvgPicture.asset("assets/icons/ic_code.svg"),
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
                "BudgetUp v${currentVersion.value}",
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
  final Widget? icon;
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
                child: icon,
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
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
