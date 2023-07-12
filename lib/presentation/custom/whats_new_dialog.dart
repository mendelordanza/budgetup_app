import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:budgetup_app/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'custom_button.dart';

class WhatsNewDialog extends HookWidget {
  const WhatsNewDialog({super.key});

  Future<String> getVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  @override
  Widget build(BuildContext context) {
    final sharedPrefs = getIt<SharedPrefs>();
    final pageController = usePageController();
    final tabPageController = useTabController(initialLength: 3);
    final currentVersion = useState("");
    final future = useMemoized(() => getVersion());
    final version = useFuture(future, initialData: "");

    useEffect(() {
      if (version.data != null) {
        currentVersion.value = version.data!;
      }
      return null;
    }, [version.data]);

    useEffect(() {
      pageController.addListener(() {
        tabPageController.index = pageController.page!.toInt();
      });
      return null;
    }, []);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16.0,
              16.0,
              0.0,
              0.0,
            ),
            child: Text(
              "What's new on v${currentVersion.value}",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // SizedBox(
                //   height: 300.0,
                //   child: PageView(
                //     controller: pageController,
                //     children: [
                //       Image.asset(
                //         "assets/ic_onboarding1.png",
                //         fit: BoxFit.fitHeight,
                //       ),
                //       Image.asset(
                //         "assets/ic_onboarding1.png",
                //         fit: BoxFit.fitHeight,
                //       ),
                //       Image.asset(
                //         "assets/ic_onboarding1.png",
                //         fit: BoxFit.fitHeight,
                //       ),
                //     ],
                //   ),
                // ),
                // Center(
                //   child: TabPageSelector(
                //     controller: tabPageController,
                //     indicatorSize: 8.0,
                //   ),
                // ),
                Text("Import and export data is here!"),
                SizedBox(
                  height: 10.0,
                ),
                Text("Separated recurring bills tabs for easier navigation"),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16.0,
              0.0,
              16.0,
              16.0,
            ),
            child: CustomButton(
              onPressed: () {
                sharedPrefs.setSeenWhatsNew(true);
              },
              child: Text(
                "I'll check it out",
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
