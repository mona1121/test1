import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pay_ready/screens/scanner_screen.dart';
import 'invoice.dart'; // Import your invoice screen

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double _totalPrice = 0.0;

  // Helper method to calculate the total price
  double _calculateTotalPrice(List<DocumentSnapshot> items) {
    return items.fold(
      0.0,
      (sum, item) {
        final price = double.tryParse(item['price'].toString()) ?? 0.0;
        final quantity = int.tryParse(item['qty'].toString()) ?? 1;
        return sum + (price * quantity);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Set elevation to 0 to remove shadow
        shadowColor: Colors.transparent, // Optional: Set shadow color to transparent
        title: const Text(
          'Cart',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ScannerScreen()),
                        );
            },
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cart').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Your cart is empty.'),
            );
          }

          final items = snapshot.data!.docs;
          _totalPrice = _calculateTotalPrice(items);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final price = double.tryParse(item['price'].toString()) ?? 0.0;

                    return ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      leading: Image.network(
                        item['image'] ?? '',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                      title: Text(
                        item['product'] ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Price: SAR ${price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('cart')
                              .doc(item.id)
                              .delete();
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Price: SAR ${_totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward, color: Colors.white),
                      onPressed: () {
                        // Navigate to the invoice screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const InvoiceScreen()),
                        );
                      },
                    ),
                  ),

                  ]
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
