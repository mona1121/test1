// thank_you_screen.dart
import 'package:flutter/material.dart';

class ThankYouScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Thank You")),
      body: Center(
        child: Text("Payment Successful! Thank you for your purchase."),
      ),
    );
  }
}
