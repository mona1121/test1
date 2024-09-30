import 'package:flutter/material.dart';

Widget buildMoreButton(BuildContext context) {
  return GestureDetector(
    onTap: () {
      // Navigate to the full transaction list page
      Navigator.pushNamed(context, '/history_transactions');
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40), // Adjusted padding for a shorter button
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white, // Set the background color to white
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey), // Optional: add a border for better visibility
      ),
      child: const Text(
        'More',
        style: TextStyle(
          color: Colors.black, // Changed text color to black for better contrast
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
  );
}
