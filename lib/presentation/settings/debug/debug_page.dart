import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class DebugPage extends StatefulWidget {
  DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  String id = "";

  getId() async {
    final customerId = await Purchases.appUserID;
    setState(() {
      id = customerId;
    });
  }

  @override
  void initState() {
    getId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Debug",
        ),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "RC ID",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(id),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: id),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Copied to clipboard")));
                  }
                  // copied successfully
                },
                icon: Icon(Iconsax.copy),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
