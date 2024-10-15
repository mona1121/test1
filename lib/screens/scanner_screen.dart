import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Updated import

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final TextEditingController _codeController = TextEditingController();
  Map<String, dynamic>? productData;
  bool isLoading = false;

  // Function to search product by code
  Future<void> searchProduct(String code) async {
    setState(() {
      isLoading = true;
      productData = null; // Clear previous data
    });

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      var querySnapshot = await firestore
          .collection('products')
          .where('code', isEqualTo: code)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          productData = querySnapshot.docs.first.data();
        });
      } else {
        setState(() {
          productData = null; // No product found
        });
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false; // Stop the loading spinner
      });
    }
  }

  // Function to scan barcode using the camera
  void scanBarcode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Scan Barcode'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context); // Go back to the previous screen
              },
            ),
          ),
          body: MobileScanner(
            onDetect: (capture) {
              final barcode = capture.barcodes.first;
              String scannedCode = barcode.rawValue ?? '';

              if (scannedCode.isNotEmpty) {
                _codeController.text = scannedCode; // Update the TextField with scanned code
                searchProduct(scannedCode);
                Navigator.pop(context); // Close the scanner screen after scanning
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product code input field
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Enter Product Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Scan barcode button
            ElevatedButton.icon(
              onPressed: scanBarcode, // Trigger the barcode scanner
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan Barcode'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue, // Replaced deprecated 'primary'
              ),
            ),

            const SizedBox(height: 10),

            // Retrieve product data by code entered
            ElevatedButton.icon(
              onPressed: () {
                if (_codeController.text.isNotEmpty) {
                  searchProduct(_codeController.text); // Search with the entered code
                }
              },
              icon: const Icon(Icons.search),
              label: const Text('Search Product'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green, // Button for searching by entered code
              ),
            ),

            const SizedBox(height: 20),

            // Display loading spinner while fetching data
            if (isLoading)
              const Center(child: CircularProgressIndicator()),

            // Display product details or "no product found"
            if (!isLoading && productData != null)
              Expanded(
                child: ListView(
                  children: [
                    Text('Product: ${productData!['product']}', style: _textStyle()),
                    Text('Brand: ${productData!['company']}', style: _textStyle()),
                    Text('Price: \$${productData!['price']}', style: _textStyle()),
                    Text('Description: ${productData!['description']}', style: _textStyle()),
                    Text('Quantity: ${productData!['qty']}', style: _textStyle()),
                    const SizedBox(height: 10),
                    if (productData!['image'] != null)
                      Image.network(productData!['image'], fit: BoxFit.cover)
                    else
                      const Text('No image available'),
                  ],
                ),
              )
            else if (!isLoading && productData == null)
              const Text('No product found.', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  // Helper method to style text
  TextStyle _textStyle() {
    return const TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  }
}
