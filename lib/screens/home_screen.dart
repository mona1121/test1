import 'package:flutter/material.dart';
import 'package:pay_ready/screens/cart_screen.dart';
import '../widgets/custom_scaffold.dart';
import '../components/navigation_bar.dart';
import 'history_transactions.dart';
import 'scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScaffold(
        child: Column(
          children: [
            // Welcome title section
            Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: const Align(
                alignment: Alignment.topCenter,
                child: Text(
                  "Welcome",
                  style: TextStyle(
                    fontFamily: 'LeagueSpartan',
                    fontSize: 40.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Empty placeholder container
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.black,
            ),

            const SizedBox(height: 20),

            // Last Transaction Section
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                color: Colors.grey[100],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Last Transactions',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Scrollable area for transactions
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 80),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTransactionSection('Today, Sept 29', [
                              _buildTransactionRow('Jarir BookStore', '09:00 AM', '238.7 SAR', 'J'),
                              const SizedBox(height: 14),
                              _buildTransactionRow('Nahdi Group', '12:00 PM', '55.87 SAR', 'N'),
                            ]),
                            const SizedBox(height: 20),
                            _buildTransactionSection('Yesterday, Sept 28', [
                              _buildTransactionRow('Whites', '07:30 AM', '55.0 SAR', 'A'),
                              const SizedBox(height: 14),
                              _buildTransactionRow('Sephora', '08:38 PM', '522.75 SAR', 'S'),
                            ]),

                            const SizedBox(height: 20),

                            // "More" button
                            _buildMoreButton(context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Floating action button for scanning
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScannerScreen()),
          );
        },
        tooltip: 'Scan',
        child: const Icon(Icons.qr_code_scanner_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom navigation bar
      bottomNavigationBar: CustomNavBar(
        onHomeTap: () {
          Navigator.pushNamed(context, '/home');
        },
        onCartTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CartScreen()),
          );
        },
        onScanTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScannerScreen()),
          );
        },
      ),
    );
  }

  // Helper methods
  Widget _buildTransactionSection(String title, List<Widget> transactions) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(),
          Column(children: transactions),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(String name, String time, String amount, String initial) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.black,
              child: Text(
                initial,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
                Text(
                  time,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HistoryTransactionsScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey),
        ),
        child: const Text(
          'More',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
