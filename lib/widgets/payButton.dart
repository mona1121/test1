import 'package:flutter/material.dart';
import '../screens/tap_payment_service.dart';

class PayButton extends StatelessWidget {
  final TapPaymentService paymentService;
  final double totalAmount;
  final String userId;

  const PayButton({
    Key? key,
    required this.paymentService,
    required this.totalAmount,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () async {
          final String currency = "SAR";
          final String description = "Invoice Payment";
          final Map<String, dynamic> customer = {
            "first_name": "test",
            "last_name": "user",
            "email": "test@example.com",
            "phone": {"country_code": "966", "number": "518234567"},
          };
          final String redirectUrl = "https://tap-payment-redirect-69z8.vercel.app/api/redirect";

          await paymentService.createCharge(
            context: context,
            amount: totalAmount,
            currency: currency,
            description: description,
            customer: customer,
            redirectUrl: redirectUrl,
            userId: userId,
          );
          
        },
        child: const Text(
          'Pay',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}