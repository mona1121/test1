import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoyaltyCard extends StatefulWidget {
  const LoyaltyCard({Key? key}) : super(key: key);

  @override
  State<LoyaltyCard> createState() => _LoyaltyCardState();
}

class _LoyaltyCardState extends State<LoyaltyCard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String userName = '';
  int points = 0;

  @override
  void initState() {
    super.initState();
    _listenToUserData();
  }

  void _listenToUserData() {
    final user = _auth.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data()!;
          setState(() {
            userName = data['name'] ?? 'User';
            points = data['points'] ?? 0;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          // Background circles
          Positioned(
            top: -20,
            left: -40,
            child: CircleAvatar(
              radius: 105,
              backgroundColor: const Color(0xFF2A7790).withOpacity(0.4),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -20,
            child: CircleAvatar(
              radius: 120,
              backgroundColor: const Color(0xFFF8C954).withOpacity(0.4),
            ),
          ),
          // Card content
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 10.0),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x525889).withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Loyalty Program',
                        style: TextStyle(
                          color: Color(0xFF383838),
                          fontWeight: FontWeight.w500,
                          fontSize: 22,
                          fontFamily: "LeagueSpartan",
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$points pts',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "LeagueSpartan",
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${1000 - points} points till your next reward',
                                style: const TextStyle(
                                  color: Colors.black45,
                                  fontSize: 17,
                                  fontFamily: "LeagueSpartan",
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.star_rounded,
                            color: const Color(0xFFFFCC3E),
                            size: 60,
                            shadows: [
                              Shadow(
                                color: const Color(0xFFC09975).withOpacity(0.4),
                                blurRadius: 40,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      LinearProgressIndicator(
                        value: points / 1200,
                        color: const Color.fromARGB(255, 57, 7, 255),
                        backgroundColor: Colors.white24,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
