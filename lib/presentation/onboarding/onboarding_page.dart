import 'package:budgetup_app/presentation/custom/custom_button.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../landing/bloc/onboarding_cubit.dart';
import '../paywall/paywall.dart';
import '../settings/currency/bloc/convert_currency_cubit.dart';

class OnboardingPage extends HookWidget {
  OnboardingPage({super.key});

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
                isFromOnboarding: true,
                offering: offerings.current!,
              );
            });
          },
        ).then((value) {
          context.read<OnboardingCubit>().finishOnboarding();
        }).onError((error, stackTrace) {
          context.read<OnboardingCubit>().finishOnboarding();
        });
      }
    } on PlatformException catch (e) {
      print(e.message);
      context.read<OnboardingCubit>().finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageController = usePageController();
    final currentIndex = useState(0);
    final pages = [
      _pageItem(
        title: "Track Daily Expenses",
        caption: "Gain control of your expneses",
        index: 1,
      ),
      _pageItem(
        title: "Track Recurring Bills",
        caption: "Never miss another payment",
        index: 2,
      ),
      _pageItem(
        title: "View Monthly Statements",
        caption: "Get a sense of your finances",
        index: 3,
      ),
      selectCurrency(context),
    ];

    useEffect(() {
      pageController.addListener(() {
        currentIndex.value = pageController.page!.toInt();
      });
      return null;
    }, []);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: PageView(
                  controller: pageController,
                  children: pages,
                ),
              ),
              CustomButton(
                onPressed: () {
                  if (currentIndex.value == pages.length - 1) {
                    showPaywall(context);
                  } else {
                    pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  }
                },
                child: currentIndex.value == pages.length - 1
                    ? Text("Let's go")
                    : Text("Next"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pageItem({
    required String title,
    required String caption,
    required int index,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w800,
          ),
        ),
        Image.asset(
          "assets/ic_onboarding$index.png",
          height: 500.0,
          fit: BoxFit.fitWidth,
        ),
        Text(
          caption,
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }

  Widget selectCurrency(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showCurrencyPicker(
          context: context,
          showFlag: true,
          showCurrencyName: true,
          showCurrencyCode: true,
          onSelect: (Currency currency) {
            context
                .read<ConvertCurrencyCubit>()
                .changeCurrency(currency.symbol, currency.code);
          },
        );
      },
      behavior: HitTestBehavior.translucent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BlocBuilder<ConvertCurrencyCubit, ConvertCurrencyState>(
            builder: (context, state) {
              if (state is ConvertedCurrencyLoaded) {
                return Text(
                  "${state.currencyCode}",
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }
              return Text(
                "Select Currency",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
          SizedBox(
            width: 5.0,
          ),
          SvgPicture.asset(
            "assets/icons/ic_arrow_down.svg",
            color: Theme.of(context).colorScheme.onSurface,
            height: 10.0,
          )
        ],
      ),
    );
  }
}
