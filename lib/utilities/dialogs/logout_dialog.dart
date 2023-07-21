import 'package:flutter/material.dart';
import 'package:whoops4/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
      context: context,
      title: "Log Out",
      content: "Are you sure you want to log out?",
      optionsBuilder: () => {
            "cancel": false,
            "Log Out": true,
          }).then(
    (value) => value ?? false,
  );
}
