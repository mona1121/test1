import 'package:flutter/material.dart';
import 'package:pay_ready/widgets/payButton.dart';
import '../firebase_auth_implementation/firebase_auth_services.dart';
import 'tap_payment_service.dart';
import 'package:intl/intl.dart';

class InvoiceScreen extends StatelessWidget {
  final List<dynamic> items;
  final String userId;
  final TapPaymentService _paymentService = TapPaymentService();

  InvoiceScreen({Key? key, required this.items, required this.userId}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final double totalAmount = _calculateTotal(items);
    final String issuedOn = DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Invoice'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            const Text(
              'Invoice',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Issued on: $issuedOn',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            const Text(
              'Invoice Items:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 10),
            InvoiceItemsTable(items: items),
            const SizedBox(height: 20),
            Text(
              'Total: SAR $totalAmount',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            PayButton(
              paymentService: _paymentService,
              totalAmount: totalAmount,
              userId: userId,
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotal(List<dynamic> items) {
    return items.fold(0.0, (sum, item) {
      final price = (item['price'] is int) ? (item['price'] as int).toDouble() : (item['price'] as double);
      final quantity = (item['quantity'] is int) ? item['quantity'] as int : (item['quantity'] as double).toInt();
      return sum + price * quantity;
    });
  }
}

class InvoiceItemsTable extends StatelessWidget {
  final List<dynamic> items;

  const InvoiceItemsTable({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        border: TableBorder.all(color: Colors.grey),
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey[200]),
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          ...items.map((item) {
            return TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(item['product'] ?? ''),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${item['quantity']}'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${item['price']} SAR'),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}
