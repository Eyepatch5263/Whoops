import 'package:flutter/material.dart';
import 'package:whoops4/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog(
      context: context,
      title: "Password reset",
      content:
          "We have now sent a password reset link. Please check Your email for more Information",
      optionsBuilder: () => {"ok": null});
}
