import 'package:budgetup_app/helper/date_helper.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  ContactPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact"),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Material(
          color: Theme.of(context).cardColor,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 16,
              cornerSmoothing: 1.0,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage('assets/icons/pic.png'),
                    radius: 80,
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  const Text(
                    "Hi, I'm Ralph! 👋",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Text(
                    "I’m a ${getMyAge()} year-old indie app developer behind this app. I hope you find this app useful as much as I did 😊\n\n"
                    "If you have questions or feedback, feel free to reach out to me:",
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      _launchEmail("ralph@trybudgetup.com");
                    },
                    child: const Row(
                      children: [
                        Icon(
                          Iconsax.sms,
                          size: 20,
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Text(
                          "ralph@trybudgetup.com",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      _launchUrl("https://twitter.com/rlphfrmthestart/");
                    },
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/icons/ic_twitter.svg",
                        ),
                        const SizedBox(
                          width: 8.0,
                        ),
                        const Text(
                          "@rlphfrmthestart",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                        )
                      ],
                    ),
                  )
                ]),
          ),
        ),
      ),
    );
  }
}
