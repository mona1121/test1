import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pay_ready/screens/ThankYou_screen.dart';
import '../widgets/tap_webview.dart';

class TapPaymentService {
  static const String _apiKey = "sk_test_XKokBfNWv6FIYuTMg5sLPjhJ";
  static const String _apiUrl = "https://api.tap.company/v2/charges";

  Future<void> createCharge({
    required BuildContext context,
    required double amount,
    required String currency,
    required String description,
    required Map<String, dynamic> customer,
    required String redirectUrl,
    required String userId,
  }) async {
    final headers = {
      "Authorization": "Bearer $_apiKey",
      "Content-Type": "application/json",
    };

    final body = json.encode({
      "amount": amount,
      "currency": currency,
      "threeDSecure": true,
      "description": description,
      "customer": customer,
      "source": {"id": "src_card"},
      "redirect": {"url": redirectUrl},
    });

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final paymentUrl = data["transaction"]["url"];

        // Show WebView
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TapPaymentWebView(paymentUrl: paymentUrl),
          ),
        );

        // Calculate and save points
        final int pointsGained = (amount / 10).floor();
        await saveTransactionToFirestore(
          userId: userId,
          transactionId: "txt_${DateTime.now().millisecondsSinceEpoch}",
          amount: amount,
          status: "success",
          pointsGained: pointsGained,
        );

        // Update user points
        await updateUserPoints(userId: userId, pointsToAdd: pointsGained);
      } else {
        throw Exception("Failed to create payment");
      }
    } catch (e) {
      print("Error: $e");
      await saveTransactionToFirestore(
        userId: userId,
        transactionId: "failed_${DateTime.now().millisecondsSinceEpoch}",
        amount: amount,
        status: "failed",
        pointsGained: 0,
      );
    }

    // Always navigate to ThankYouScreen after the WebView
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ThankYouScreen()),
    );
  }

  Future<void> saveTransactionToFirestore({
    required String userId,
    required String transactionId,
    required double amount,
    required String status,
    required int pointsGained,
  }) async {
    final transactionData = {
      "transactionId": transactionId,
      "amount": amount,
      "currency": "SAR",
      "status": status,
      "pointsGained": pointsGained,
      "createdAt": FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transaction_history')
        .add(transactionData);
  }

  Future<void> updateUserPoints({
    required String userId,
    required int pointsToAdd,
  }) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      if (userSnapshot.exists) {
        final currentPoints = userSnapshot.data()?["points"] ?? 0;
        transaction.update(userRef, {"points": currentPoints + pointsToAdd});
      }
    });
  }
}
