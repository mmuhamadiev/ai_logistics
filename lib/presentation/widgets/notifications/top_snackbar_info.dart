import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

void showTopSnackbarInfo(BuildContext context, String content) {
  showTopSnackBar(
    Overlay.of(context),
    CustomSnackBar.info(
      message: content
    ),
  );
}