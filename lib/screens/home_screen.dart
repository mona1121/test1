import 'package:flutter/material.dart';
import 'package:pay_ready/screens/cart_screen.dart';
import '../firebase_auth_implementation/firebase_auth_services.dart';
import '../widgets/home_scaffold.dart';
import '../components/navigation_bar.dart';
import '../widgets/loyalty_card.dart';
import 'history_transactions.dart';
import 'scanner_screen.dart';
import 'edit_profile.dart';
import 'contactUs.dart';
import '../widgets/transaction_history.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final FirebaseAuthService _auth = FirebaseAuthService();

   Future<void> _handleSignOut() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/welcome');
  }
 
 void _onMenuItemSelected(String choice) {
    switch (choice) {
      case 'Edit Profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditProfile()),
        );
        break;
      case 'Contact Us':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ContactUs()),
        );
        break;
      case 'Sign Out':
        _handleSignOut();
        break;
    }
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeScaffold(
        onMenuItemSelected: _onMenuItemSelected,
        menuItems: const [
        PopupMenuItem(
          value: 'Edit Profile',
          child: ListTile(
            leading: Icon(Icons.edit, color: Colors.black),
            title: Text('Edit Profile'),
          ),
        ),
        PopupMenuItem(
          value: 'Contact Us',
          child: ListTile(
            leading: Icon(Icons.help_outline, color: Colors.black),
            title: Text('Contact Us'),
          ),
        ),
        PopupMenuItem(
          value: 'Sign Out',
          child: ListTile(
            leading: Icon(Icons.logout, color: Colors.black),
            title: Text('Sign Out'),
          ),
        ),
      ],
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
                    fontFamily: 'LeagueSpartan' ,
                   fontWeight: FontWeight.w700,
                   fontSize: 46,
                   color: Colors.black,
                  ),
                ),
              ),
            ),

            

            // Loyalty card
             const LoyaltyCard(),

            

            // Last Transaction Section
            const TransactionHistory(),


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