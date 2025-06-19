import 'package:flutter/cupertino.dart';
import 'package:ai_logistics_management_order_automation/presentation/widgets/quickalert/lib/models/quickalert_type.dart';
import 'package:ai_logistics_management_order_automation/presentation/widgets/quickalert/lib/widgets/quickalert_dialog.dart';


void showErrorNotification(BuildContext context, String error) {
  QuickAlert.show(
    context: context,
    type: QuickAlertType.error,
    title: 'Oops...',
    text: error,
  );
}