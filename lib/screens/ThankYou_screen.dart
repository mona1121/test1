import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

class ThankYouScreen extends StatelessWidget {
  final TransactionDetails transactionDetails;

  const ThankYouScreen({Key? key, required this.transactionDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String qrData = jsonEncode({
      'transactionId': transactionDetails.transactionId,
      'amount': transactionDetails.amount,
      'date': transactionDetails.date,
      'userId': transactionDetails.userId,
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Thank You!",
        style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 100, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              "Payment Successful!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Transaction ID: ${transactionDetails.transactionId}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            // QR Code Section
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                 Container(
                  child: QrImageView(
                    data: qrData,
                    size: 200,
                    backgroundColor: Colors.white,
                    version: QrVersions.auto,
                  ),
                ),
                  const SizedBox(height: 8),
                  const Text(
                    "Place your phone on the gate scanner to open it",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),

            ),
            const SizedBox(height: 24),
            ElevatedButton(
                      style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home', // Adjust your home route here
                        (route) => false,
                      );
                            },
                      child: const Text('Return to Home'),
                    ),
          ],
        ),
      ),
    );
  }
}

class TransactionDetails {
  final String transactionId;
  final double amount;
  final String date;
  final String userId;
  final String status;

  TransactionDetails({
    required this.transactionId,
    required this.amount,
    required this.date,
    required this.userId,
    required this.status,
  });
}
