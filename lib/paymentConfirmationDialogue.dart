import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash/custom_provider.dart';
import 'package:http/http.dart' as https;
import 'package:splash/pay.dart';

class PaymentConfirmationDialog extends StatefulWidget {
  final int amount;
  final String location;
  final String comment;

  const PaymentConfirmationDialog({
    Key? key,
    this.amount = 0,
    this.location = '',
    this.comment = '',
  }) : super(key: key);

  @override
  State<PaymentConfirmationDialog> createState() =>
      _PaymentConfirmationDialogState();
}

class _PaymentConfirmationDialogState extends State<PaymentConfirmationDialog> {
  bool _isLoading = false;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  void _handleYes() async {
    setState(() {
      _isLoading = true;
    });
    _prefs.then((SharedPreferences prefs) async {
      final appState = Provider.of<AppState>(context, listen: false);
      try {
        final response = await https.post(
          Uri.parse('https://cafe.sbigeneral.in/Cafe/getDeductBalance'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            "Accept": "application/json",
            "Authorization": 'Bearer ${appState.accessToken}'
          },
          body: jsonEncode(<String, dynamic>{
            'user_Id': prefs.getInt("puserId").toString(),
            'amount_deduct': widget.amount,
            'location': widget.location,
            'remark': widget.comment,
          }),
        );
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (response.statusCode == 200) {
          setState(() {
            _isLoading = false;
          });
          print(data);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => DoneScreen(
                      amount: widget.amount.toString(),
                      location: widget.location,
                    )),
          );
        }
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        appState.showTechnicalError(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Container(
        padding: const EdgeInsets.all(15.0),
        height: 200.0, // Adjusted for potential loading text and animation
        width: 300.0,
        child: Stack(
          children: <Widget>[
            if (!_isLoading) ...[
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Payment Confirmation',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Do you want to pay ₹ ${widget.amount}?',
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('No',
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 16)),
                        ),
                        TextButton(
                          onPressed: _handleYes,
                          child: const Text('Yes',
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 16)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(color: Colors.white),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Payment processing...',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF700C79)),
                      ),
                      const SizedBox(height: 10),
                      LoadingAnimationWidget.threeArchedCircle(
                        color: const Color.fromRGBO(112, 12, 121, 1),
                        size: 50,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
