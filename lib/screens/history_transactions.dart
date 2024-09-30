import 'package:flutter/material.dart';

class HistoryTransactionsScreen extends StatelessWidget {
  const HistoryTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Transaction History",
          style: TextStyle(
            fontFamily: 'LeagueSpartan',
            fontSize: 24.0, // Adjusted font size for AppBar
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white, // Set app bar color
        elevation: 0, // Remove the elevation for a flat look
      ),
      body: Container(
        color: Colors.white, // Set the screen background color
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // List of transactions
            Expanded(
              child: ListView(
                children: [
                  _buildTransactionDay('Today, Sept 29', [
                    _buildTransactionRow('Jarir BookStore', '09:00 AM', '238.7 SAR'),
                    _buildTransactionRow('Nahdi Group', '12:00 PM', '55.87 SAR'),
                  ]),
                  const SizedBox(height: 16),
                  _buildTransactionDay('Yesterday, Sept 28', [
                    _buildTransactionRow('Whites', '07:30 AM', '55.0 SAR'),
                    _buildTransactionRow('Sephora', '08:38 PM', '522.75 SAR'),
                  ]),
                  const SizedBox(height: 16),
                  _buildTransactionDay('Sept 27', [
                    _buildTransactionRow('Starbucks', '10:00 AM', '20.0 SAR'),
                    _buildTransactionRow('McDonald\'s', '01:00 PM', '35.0 SAR'),
                  ]),
                  const SizedBox(height: 16),
                  _buildTransactionDay('Sept 26', [
                    _buildTransactionRow('Home Center', '03:00 PM', '120.0 SAR'),
                    _buildTransactionRow('Extra', '05:00 PM', '89.99 SAR'),
                  ]),
                  const SizedBox(height: 16),
                  _buildTransactionDay('Sept 25', [
                    _buildTransactionRow('IKEA', '02:30 PM', '300.0 SAR'),
                    _buildTransactionRow('Carrefour', '06:15 PM', '250.0 SAR'),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a transaction day section
  Widget _buildTransactionDay(String day, List<Widget> transactions) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey), // Optional: add a border for better visibility
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: transactions,
          ),
        ],
      ),
    );
  }

  // Helper method to build a single transaction row
  Widget _buildTransactionRow(String name, String time, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        Text(
          amount,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
