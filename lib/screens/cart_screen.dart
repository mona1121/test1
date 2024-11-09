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
  double _calculateTotalPrice(List<Map<String, dynamic>> items) {
    return items.fold(0.0, (sum, item) {
      final price = double.tryParse(item['price'].toString()) ?? 0.0;
      final quantity = item['quantity'] ?? 1; // Use custom quantity
      return sum + (price * quantity);
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Cart',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      iconTheme: const IconThemeData(color: Colors.black),
      actions: [
        IconButton(
          icon: const Icon(Icons.add, color: Colors.black),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ScannerScreen()));
          },
        ),
      ],
    ),
    body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('cart').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Your cart is empty.'));
        }

        // Mapping Firestore data to a list and including the quantity
        final items = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'image': data['image'],
            'product': data['product'],
            'price': data['price'],
            'quantity': data['quantity'] ?? 1, // Retrieve quantity from Firestore
          };
        }).toList();

        _totalPrice = _calculateTotalPrice(items);

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final price = double.tryParse(item['price'].toString()) ?? 0.0;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Image.network(
                          item['image'] ?? '',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['product'] ?? '',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Price: SAR ${price.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    if (item['quantity'] > 1) {
                                      FirebaseFirestore.instance
                                          .collection('cart')
                                          .doc(item['id'])
                                          .update({'quantity': FieldValue.increment(-1)});
                                    } else {
                                      FirebaseFirestore.instance
                                          .collection('cart')
                                          .doc(item['id'])
                                          .delete();
                                    }
                                  },
                                ),
                                Text('${item['quantity']}', style: const TextStyle(fontSize: 18)),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('cart')
                                        .doc(item['id'])
                                        .update({'quantity': FieldValue.increment(1)});
                                  },
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                FirebaseFirestore.instance.collection('cart').doc(item['id']).delete();
                              },
                            ),
                          ],
                        ),
                      ],
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
                  Text('Total Price: SAR ${_totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Container(
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward, color: Colors.white),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => InvoiceScreen(items: items)));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}

}
