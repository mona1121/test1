/*

import 'package:flutter/material.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  String _scanResult = 'Scan a code';

  Future<void> scanBarcode() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Color of the scan line
        'Cancel', // Text for cancel button
        true, // Show a flash icon
        ScanMode.BARCODE, // Scan mode (BARCODE or QR)
      );
    } catch (e) {
      barcodeScanRes = 'Failed to get barcode: $e';
    }

    if (!mounted) return;

    setState(() {
      _scanResult = barcodeScanRes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Scan result: $_scanResult'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: scanBarcode,
              child: const Text('Start Scan'),
            ),
          ],
        ),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key}); // Use const constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('scan'),
      ),
      body: const Center(
        child: Text('scan'),
      ),
    );
  }
}