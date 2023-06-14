import 'package:budgetup_app/presentation/paywall/paywall.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
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
                        settingItems: [
                          SettingItem(
                            onTap: () {
                              showModalBottomSheet(context: context, builder: (context) {
                                return Paywall();
                              });
                            },
                            icon: "assets/icons/ic_app_icon.svg",
                            iconBackgroundColor: Color(0xFF666666),
                            label: "Subscribe to BudgetUp Pro",
                          ),
                        ],
                      ),
                      SettingsContainer(
                        label: "App",
                        settingItems: [
                          SettingItem(
                              onTap: () {},
                              icon: "assets/icons/ic_summary.svg",
                              iconBackgroundColor: Color(0xFFfc7f03),
                              label: "Summary Reports"),
                          Divider(),
                          SettingItem(
                              onTap: () {},
                              icon: "assets/icons/ic_moon.svg",
                              iconBackgroundColor: Color(0xFF9300ED),
                              label: "Appearance"),
                          Divider(),
                          SettingItem(
                              onTap: () {},
                              icon: "assets/icons/ic_currency.svg",
                              iconBackgroundColor: Color(0xFF00A61B),
                              label: "Currency"),
                          // Divider(),
                          // SettingItem(
                          //     icon: "assets/icons/ic_import_export.svg",
                          //     iconBackgroundColor: Color(0xFFC26900),
                          //     label: "Import / Export Data"),
                        ],
                      ),
                      SettingsContainer(
                        label: "General",
                        settingItems: [
                          SettingItem(
                              onTap: () {},
                              icon: "assets/icons/ic_star.svg",
                              iconBackgroundColor: Color(0xFFFFC700),
                              label: "Rate the app"),
                          Divider(),
                          SettingItem(
                              onTap: () {},
                              icon: "assets/icons/ic_share.svg",
                              iconBackgroundColor: Color(0xFFB43D3D),
                              label: "Share the app"),
                          Divider(),
                          SettingItem(
                              onTap: () {},
                              icon: "assets/icons/ic_send.svg",
                              iconBackgroundColor: Color(0xFF0069B6),
                              label: "Send feedback"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                children: [
                  Text(
                    "BudgetUp v1.0",
                    style: TextStyle(fontSize: 12.0),
                  ),
                  Text(
                    "Made with ❤️ by Ralph Ordanza",
                    style: TextStyle(fontSize: 12.0),
                  ),
                ],
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

  SettingsContainer({
    this.label,
    required this.settingItems,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16.0,
      ),
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
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(40.0),
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
  final String icon;
  final String? iconSize;
  final Color iconBackgroundColor;
  final String label;

  SettingItem({
    required this.onTap,
    required this.icon,
    this.iconSize,
    required this.iconBackgroundColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              height: 30.0,
              width: 30.0,
              padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: SvgPicture.asset(
                icon,
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
              child: Text(
                label,
              ),
            ),
            SvgPicture.asset(
              "assets/icons/ic_arrow_right.svg",
            ),
          ],
        ),
      ),
    );
  }
}
