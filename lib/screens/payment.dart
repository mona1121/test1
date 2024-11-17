import 'package:flutter/material.dart';
import '../screens/tap_payment_service.dart';
import '../screens/ThankYou_screen.dart';

class PayButton extends StatelessWidget {
  final TapPaymentService paymentService;
  final double totalAmount;

  const PayButton({Key? key, required this.paymentService, required this.totalAmount}) : super(key: key);

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
          try {
            final String currency = "SAR";
            final String description = "Invoice Payment";
            final Map<String, dynamic> customer = {
              "first_name": "test",
              "last_name": "user",
              "email": "test@example.com",
              "phone": {"country_code": "965", "number": "51234567"},
            };
            final String redirectUrl = "https://tap-payment-redirect-69z8.vercel.app/api/redirect";

            await paymentService.createCharge(
              context: context,
              amount: totalAmount,
              currency: currency,
              description: description,
              customer: customer,
              redirectUrl: redirectUrl,
             userId: ' ',
            );
            // Create a TransactionDetails object (replace with actual data)
            final transactionDetails = TransactionDetails(
              transactionId: 'transactionId', // Replace with the real transaction ID
              amount: totalAmount,
              date: DateTime.now().toString(),
              userId: 'userId', // Replace with the real user ID
              status: 'Success', // Replace with the actual payment status
            );

            // Navigate to ThankYouScreen on successful payment
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ThankYouScreen(transactionDetails: transactionDetails),
              ),
            );
          } catch (e) {
            print("Error creating payment: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Payment failed: $e")),
            );
          }
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