// payment.dart
import 'package:flutter/material.dart';
import "CardViewScreen.dart";

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> dictionaryMap;

  const PaymentScreen({Key? key, required this.dictionaryMap}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? paymentStatus = "Initiating Payment...";

  void _startCardViewScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardViewScreen(),
      ),
    );

    setState(() {
      paymentStatus = result ?? "No response from CardViewScreen";
    });
  }

  @override
  void initState() {
    super.initState();
    // Directly start CardViewScreen when PaymentScreen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCardViewScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                paymentStatus ?? "Processing...",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _startCardViewScreen,
                child: const Text("Try Again"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
