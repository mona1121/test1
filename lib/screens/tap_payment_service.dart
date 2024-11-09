// tap_payment_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class TapPaymentService {
  static const String apiUrl = "https://pay-ready.onrender.com/create_payment/";

  Future<void> createCharge({
    required double amount,
    required String currency,
    required String description,
    required Map<String, dynamic> customer,
    required String redirectUrl,
  }) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "amount": amount,
        "currency": currency,
        "description": description,
        "customer": customer,
        "redirect_url": redirectUrl,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final paymentUrl = data["transaction"]["url"];
      if (paymentUrl != null) {
        if (await canLaunch(paymentUrl)) {
          await launch(paymentUrl);
        } else {
          throw Exception("Could not launch $paymentUrl");
        }
      } else {
        throw Exception("Payment URL not found in response.");
      }
    } else {
      throw Exception("Failed to create payment: ${response.body}");
    }
  }
}
