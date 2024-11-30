import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart_screen.dart';

class ProductIdentificationScreen extends StatelessWidget {
  final Map<String, dynamic> productData;

  const ProductIdentificationScreen({Key? key, required this.productData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Product Identification', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (productData['image'] != null)
              Center(
                child: Image.network(
                  productData['image'],
                  fit: BoxFit.contain,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, size: 100);
                  },
                ),
              )
            else
              const Center(
                child: Text(
                  'No image available',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              productData['product'] ?? 'Unknown Product',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              productData['company'] ?? 'Unknown Company',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Text(
              productData['description'] ?? 'No description available.',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'SAR ${_formatPrice(productData['price'])}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () async {
                  await _addToCart(productData);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
                child: const Text('Add to Cart'),
              ),
            ),
            const SizedBox(height: 30),
            const Text('You may also like:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(height: 150, child: _buildRecommendations()),
          ],
        ),
      ),
    );
  }

  String _formatPrice(dynamic price) {
    if (price is String) {
      return price;
    } else if (price is double || price is int) {
      return price.toStringAsFixed(2);
    }
    return '0.00';
  }

  Future<void> _addToCart(Map<String, dynamic> product) async {
    final cartCollection = FirebaseFirestore.instance.collection('cart');
    final existingProduct = await cartCollection.where('code', isEqualTo: product['code']).limit(1).get();

    if (existingProduct.docs.isNotEmpty) {
      await cartCollection.doc(existingProduct.docs.first.id).update({
        'quantity': FieldValue.increment(1),
      });
    } else {
      await cartCollection.doc(product['code']).set({
        'code': product['code'],
        'image': product['image'],
        'product': product['product'],
        'price': product['price'] is String
            ? double.tryParse(product['price']) ?? 0.0
            : product['price'],
        'quantity': 1,
      });
    }
  }

  Future<List<dynamic>> _fetchRecommendations(String code) async {
    final response = await http.get(Uri.parse('https://pay-ready.onrender.com/recommendations/$code'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load recommendations');
    }
  }

  Widget _buildRecommendations() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchRecommendations(productData['code']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text('Error fetching recommendations.');
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No recommendations available.');
        }
        return _buildHorizontalList(snapshot.data!);
      },
    );
  }

  Widget _buildHorizontalList(List<dynamic> recommendations) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        final recommendedProduct = recommendations[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductIdentificationScreen(productData: recommendedProduct),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: recommendedProduct['image'] != null
                      ? Image.network(
                          recommendedProduct['image'],
                          fit: BoxFit.contain,
                        )
                      : const Icon(Icons.image_not_supported, size: 50),
                ),
                const SizedBox(height: 5),
                Text(
                  recommendedProduct['product'],
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'SAR ${recommendedProduct['price']}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
