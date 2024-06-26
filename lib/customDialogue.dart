import 'package:flutter/material.dart';
import 'package:splash/paymentConfirmationDialogue.dart';

void showCustomDialog(BuildContext context,
    {amount = 0, location='', comment='' ,}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return PaymentConfirmationDialog(amount: int.parse(amount), location: location, comment: comment,);
     },
  );
}
