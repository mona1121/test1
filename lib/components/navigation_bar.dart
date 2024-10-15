import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final Function onHomeTap;
  final Function onCartTap;
  final Function onScanTap;

  const CustomNavBar({
    super.key,
    required this.onHomeTap,
    required this.onCartTap,
    required this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Home Button
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => onHomeTap(),
          ),
          // Scan Button Placeholder
          const SizedBox(width: 40), 
          // Cart Button
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => onCartTap(),
          ),
        ],
      ),
    );
  }
}
