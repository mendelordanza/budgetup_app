import 'package:budgetup_app/helper/colors.dart';
import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:budgetup_app/injection_container.dart';
import 'package:budgetup_app/presentation/settings/appearance/bloc/appearance_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';

import '../settings_page.dart';

enum AppearanceType {
  dark,
  light,
  system,
}

class ApperancePage extends HookWidget {
  const ApperancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sharedPrefs = getIt<SharedPrefs>();
    final currentAppearance =
        appearanceTypeFromString(sharedPrefs.getAppearance());
    final _selectedAppearance = useState<AppearanceType>(currentAppearance);

    return Scaffold(
      appBar: AppBar(
        title: Text("Appearance"),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SettingsContainer(
            settingItems: [
              SettingItem(
                onTap: () {
                  _selectedAppearance.value = AppearanceType.dark;
                  context
                      .read<AppearanceCubit>()
                      .setAppearance(_selectedAppearance.value);
                },
                label: "Dark",
                suffix: _selectedAppearance.value == AppearanceType.dark
                    ? Icon(
                        Iconsax.tick_circle,
                        color: secondaryColor,
                      )
                    : null,
              ),
              Divider(),
              SettingItem(
                onTap: () {
                  _selectedAppearance.value = AppearanceType.light;
                  context
                      .read<AppearanceCubit>()
                      .setAppearance(_selectedAppearance.value);
                },
                label: "Light",
                suffix: _selectedAppearance.value == AppearanceType.light
                    ? Icon(
                        Iconsax.tick_circle,
                        color: secondaryColor,
                      )
                    : null,
              ),
              Divider(),
              SettingItem(
                onTap: () {
                  _selectedAppearance.value = AppearanceType.system;
                  context
                      .read<AppearanceCubit>()
                      .setAppearance(_selectedAppearance.value);
                },
                label: "System",
                suffix: _selectedAppearance.value == AppearanceType.system
                    ? Icon(
                        Iconsax.tick_circle,
                        color: secondaryColor,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
