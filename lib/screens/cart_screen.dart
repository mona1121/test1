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