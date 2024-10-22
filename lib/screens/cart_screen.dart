/*
import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key}); // Use const constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: const Center(
        child: Text('Your cart items will be displayed here.'),
      ),
    );
  }
}

 */

// cart_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Model for CartItem
class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String description;
  final String image;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.description,
    required this.image,
  });

  // Convert CartItem from Firestore snapshot
  factory CartItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CartItem(
      id: doc.id,
      name: data['name'],
      price: data['price'].toDouble(),
      quantity: data['quantity'],
      description: data['description'],
      image: data['image'],
    );
  }

  // Convert CartItem to JSON (if needed for other operations)
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'quantity': quantity,
    'description': description,
    'image': image,
  };
}

// CartScreen class that displays the cart items from Firestore.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('cartItems') // The Firestore collection for cart items
            .snapshots(), // Stream of real-time updates from Firestore
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Your cart is empty.'),
            );
          }

          // Convert Firestore documents to CartItem objects
          final items = snapshot.data!.docs
              .map((doc) => CartItem.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: Image.network(item.image), // Display product thumbnail
                title: Text(item.name),
                subtitle: Text(
                    '${item.description}\nPrice: \$${item.price} x ${item.quantity}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // Remove item from Firestore
                    FirebaseFirestore.instance
                        .collection('cartItems')
                        .doc(item.id)
                        .delete();
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Example of adding a new item to Firestore
          final newItem = CartItem(
            id: DateTime.now().toString(),
            name: 'Sample Product',
            price: 15.0,
            quantity: 1,
            description: 'A sample product description',
            image:
            'https://via.placeholder.com/150', // Placeholder thumbnail URL
          );

          // Add new item to Firestore
          FirebaseFirestore.instance.collection('cartItems').add(newItem.toJson());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
