import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart_screen.dart';
import 'package:http/http.dart' as http;

class ProductIdentificationScreen extends StatelessWidget {
  final Map<String, dynamic> productData;

  const ProductIdentificationScreen({Key? key, required this.productData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Product Identification'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Centered and scaled-down product image
              if (productData['image'] != null)
                Center(
                  child: Image.network(
                    productData['image'],
                    fit: BoxFit.contain,
                    height: 200, // Adjust height for scaling without cropping
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

              // Product information display
              Text(
                productData['product'] ?? '',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                productData['company'] ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                productData['description'] ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              // Price in SAR, bold and aligned to the right
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'SAR ${productData['price'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Add to Cart Button
              Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Button background color
                  foregroundColor: Colors.white, // Button text color
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () async {
                  await _addToCart();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
                child: const Text('Add to Cart'),
              ),
            ),
              const SizedBox(height: 30),

              // Recommendations Section
              const Text('You may also like:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // Display recommendations in a horizontal list
              SizedBox(
                height: 150, // Fixed height for horizontal ListView
                child: _buildRecommendations(),
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

  // Add to Cart function
  Future<void> _addToCart() async {
    final cartCollection = FirebaseFirestore.instance.collection('cart');
    await cartCollection.add(productData);
  }

  // Method to build the recommendations section
  Widget _buildRecommendations() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchRecommendations(productData['code']), // Pass the product code to fetch recommendations
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

// Method to fetch recommendations from FastAPI
  Future<List<dynamic>> _fetchRecommendations(String code) async {
    final response = await http.get(
      Uri.parse('https://pay-ready.onrender.com/recommendations/$code'), // FastAPI URL with path parameter
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load recommendations');
    }
  }

  // Helper method to build a horizontal list of recommendations
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
              crossAxisAlignment: CrossAxisAlignment.center,
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
                          fit: BoxFit.contain, // Scale down without cropping
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
