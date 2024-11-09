import 'package:flutter/material.dart';
import 'package:pay_ready/widgets/payButton.dart';
import 'tap_payment_service.dart';

class InvoiceScreen extends StatelessWidget {
  final List<dynamic> items;
  final TapPaymentService _paymentService = TapPaymentService();

  InvoiceScreen({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double totalAmount = _calculateTotal(items);

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
            const Text(
              'Issued on:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey),
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
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotal(List<dynamic> items) {
    return items.fold(0.0, (sum, item) {
      final price = double.tryParse(item['price'].toString()) ?? 0.0;
      final quantity = int.tryParse(item['qty'].toString()) ?? 1;
      return sum + (price * quantity);
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
                  child: Text('${item['qty']}'),
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
