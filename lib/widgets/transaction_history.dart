import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionHistory extends StatelessWidget {
  const TransactionHistory({Key? key}) : super(key: key);

  Future<Map<String, List<QueryDocumentSnapshot>>> _fetchTransactions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {};
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transaction_history')
          .orderBy('createdAt', descending: true)
          .get();

      final Map<String, List<QueryDocumentSnapshot>> groupedByMonth = {};

      for (var doc in querySnapshot.docs) {
        final timestamp = doc['createdAt'] as Timestamp;
        final date = timestamp.toDate();
        final formattedMonth = "${_getMonthName(date.month)} ${date.year}";

        groupedByMonth.putIfAbsent(formattedMonth, () => []);
        groupedByMonth[formattedMonth]!.add(doc);
      }

      return groupedByMonth;
    } catch (e) {
      debugPrint("Error fetching transactions: $e");
      return {};
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
        color: Colors.grey[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last Transactions',
              style: TextStyle(
                fontFamily: 'LeagueSpartan' ,
                fontWeight: FontWeight.w700,
                fontSize: 33,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<Map<String, List<QueryDocumentSnapshot>>>(
                future: _fetchTransactions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading transactions.'));
                  }

                  final groupedTransactions = snapshot.data ?? {};
                  if (groupedTransactions.isEmpty) {
                    return const Center(child: Text('No transactions found.'));
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var entry in groupedTransactions.entries)
                          _buildTransactionSection(
                              context, entry.key, entry.value),
                        const SizedBox(height: 20),
                        buildMoreButton(context),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionSection(BuildContext context, String month, List<QueryDocumentSnapshot> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          month,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: transactions.take(4).map((transaction) {
              final data = transaction.data() as Map<String, dynamic>;
              final timestamp = data['createdAt'] as Timestamp;
              final date = timestamp.toDate();
              final day = date.day.toString();
              final time = _formatTime(date);
              final transactionId = data['transactionId'];
              final amount = data['amount'];
              final currency = data['currency'];

              return Column(
                children: [
                  _buildTransactionRow(day, transactionId, time, '$amount $currency'),
                  const SizedBox(height: 14),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTransactionRow(String day, String name, String time, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.black,
              child: Text(
                day,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        Text(
          amount,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}

Widget buildMoreButton(BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(context, '/history_transactions');
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
