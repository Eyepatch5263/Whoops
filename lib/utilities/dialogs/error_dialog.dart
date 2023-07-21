import 'package:flutter/material.dart';
import 'package:whoops4/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog<void>(
      context: context,
      title: "An error Occurred",
      content: text,
      optionsBuilder: ()=>{
        "Ok":null,
      });
}
