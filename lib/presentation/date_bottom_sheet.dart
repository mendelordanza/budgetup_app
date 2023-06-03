import 'package:flutter/material.dart';

class DateBottomSheet extends StatelessWidget {
  const DateBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16.0,
        16.0,
        16.0,
        24.0,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(context),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _tab(context, "Daily"),
                    _tab(context, "Weekly"),
                    _tab(context, "Monthly"),
                    _tab(context, "Yearly"),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _tab(
    BuildContext context,
    String label,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 5.0,
        horizontal: 16.0,
      ),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Text(label),
    );
  }

  Widget _buildHandle(BuildContext context) {
    final theme = Theme.of(context);

    return FractionallySizedBox(
      widthFactor: 0.25,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 12.0,
        ),
        child: Container(
          height: 5.0,
          decoration: BoxDecoration(
            color: theme.dividerColor,
            borderRadius: const BorderRadius.all(Radius.circular(2.5)),
          ),
        ),
      ),
    );
  }
}
