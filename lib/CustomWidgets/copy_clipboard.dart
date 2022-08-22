import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:gem/CustomWidgets/snackbar.dart';

void copyToClipboard({
  required BuildContext context,
  required String text,
  String? displayText,
}) {
  Clipboard.setData(
    ClipboardData(text: text),
  );
  ShowSnackBar().showSnackBar(
    context,
    displayText ?? 'Copied',
  );
}
