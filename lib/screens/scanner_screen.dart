import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'product_identification.dart'; // Import the Product Identification screen

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final TextEditingController _codeController = TextEditingController();
  Map<String, dynamic>? productData;
  bool isLoading = false;
  bool showPopup = false;
  bool isScanning = false; // To track if we're currently processing a scan

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
          showPopup = true; // Show the popup after fetching product data
        });
      } else {
        setState(() {
          productData = null; // No product found
          showPopup = false; // Hide the popup
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
    setState(() {
      showPopup = false; // Hide the popup when starting a new scan
      isScanning = false; // Reset scanning state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Search'),
      ),
      body: Stack(
        children: [
          // Barcode Scanner
          MobileScanner(
            onDetect: (capture) {
              if (isScanning) return; // Ignore further detections if already scanning
              final barcode = capture.barcodes.first;
              String scannedCode = barcode.rawValue ?? '';

              if (scannedCode.isNotEmpty) {
                _codeController.text = scannedCode; // Update the TextField with scanned code
                isScanning = true; // Set scanning to true
                searchProduct(scannedCode);

                // Delay to avoid multiple detections for the same barcode
                Future.delayed(const Duration(seconds: 2), () {
                  setState(() {
                    isScanning = false; // Allow new scans after the delay
                  });
                });
              }
            },
          ),

          // Show loading spinner while fetching data
          if (isLoading)
            const Center(child: CircularProgressIndicator()),

          // Show popup with product information
          if (showPopup && productData != null)
            Positioned(
              bottom: 50, // Adjust as necessary
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8.0,
                      spreadRadius: 1.0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (productData!['image'] != null)
                      Image.network(
                        productData!['image'],
                        fit: BoxFit.cover,
                        height: 50,
                        width: 50,
                      ),
                    const SizedBox(height: 10),
                    Text(
                      'Product: ${productData!['product']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Brand: ${productData!['company']}'),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              showPopup = false; // Close the popup
                            });
                            scanBarcode(); // Optionally reset scanner state
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the popup
                            // Navigate to the Product Identification page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductIdentificationScreen(productData: productData!),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
