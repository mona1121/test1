import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_screen.dart'; // Import the CartScreen from previous code

class ProductIdentificationScreen extends StatelessWidget {
  final Map<String, dynamic> productData;

  const ProductIdentificationScreen({Key? key, required this.productData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Identification'),
      ),
      body: SingleChildScrollView( // Wrap Column with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              if (productData['image'] != null)
                Image.network(productData['image'], fit: BoxFit.cover)
              else
                const Text('No image available', style: TextStyle(color: Colors.red)),

              const SizedBox(height: 20),

              // Product details
              Text('Product: ${productData['product']}', style: _textStyle()),
              Text('Brand: ${productData['company']}', style: _textStyle()),
              Text('Price: \$${productData['price']}', style: _textStyle()),
              Text('Description: ${productData['description']}', style: _textStyle()),

              const SizedBox(height: 30),

              // Add to Cart Button
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // Add the product to the Firestore cart collection
                    await _addToCart();

                    // Navigate to the CartScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartScreen()),
                    );
                  },
                  child: const Text('Add to Cart'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to style text
  TextStyle _textStyle() {
    return const TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  }

  // Method to add the product to the Firestore cart collection
  Future<void> _addToCart() async {
    final cartItem = {
      'name': productData['product'],
      'price': productData['price'],
      'quantity': 1, // Default quantity is 1
      'description': productData['description'],
      'image': productData['image'],
    };

    // Add the product data to the Firestore collection 'cartItems'
    await FirebaseFirestore.instance.collection('cartItems').add(cartItem);
  }
}
