import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'scanner_screen.dart';
import 'invoice.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double _totalPrice = 0.0;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    setState(() {
      _currentUser = FirebaseAuth.instance.currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if userId is available
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cart'),
        ),
        body: const Center(
          child: Text('Please log in to view your cart.'),
        ),
      );
    }

    final String userId = _currentUser!.uid;

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

          final items = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              'image': data['image'],
              'product': data['product'],
              'price': data['price'],
              'quantity': data['quantity'] ?? 1,
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
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      if (item['quantity'] > 1) {
                                        FirebaseFirestore.instance.collection('cart').doc(item['id']).update({
                                          'quantity': FieldValue.increment(-1),
                                        });
                                      }
                                    },
                                  ),
                                  Text('${item['quantity']}'),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      FirebaseFirestore.instance.collection('cart').doc(item['id']).update({
                                        'quantity': FieldValue.increment(1),
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
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
                child: Column(
                  children: [
                    Text(
                      'Total: SAR ${_totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => InvoiceScreen(items: items, userId: userId)),

                        );
                      },
                      child: const Text('Proceed to Payment'),
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

  double _calculateTotalPrice(List<Map<String, dynamic>> items) {
    return items.fold(
      0.0,
      (total, item) {
        final price = (item['price'] is int) ? (item['price'] as int).toDouble() : (item['price'] as double);
        final quantity = (item['quantity'] is int) ? item['quantity'] as int : (item['quantity'] as double).toInt();
        return total + price * quantity;
      },
    );
  }
}