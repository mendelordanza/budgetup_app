import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:keyboard_actions/keyboard_actions_config.dart';

KeyboardActionsConfig buildConfig(FocusNode focusNode, BuildContext context) {
  return KeyboardActionsConfig(
    keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
    keyboardBarColor: Theme.of(context).scaffoldBackgroundColor,
    actions: [
      KeyboardActionsItem(
        focusNode: focusNode,
        toolbarButtons: [
          (node) {
            return TextButton(
              onPressed: () => node.unfocus(),
              child: Text(
                "DONE",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            );
          }
        ],
      ),
    ],
  );
}
