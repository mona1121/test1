import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:test1/screens/home_screen.dart';
import 'package:test1/screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized
  await Firebase.initializeApp();  // Initialize Firebase
  runApp(const Test1());  // Run the main app
}

class Test1 extends StatelessWidget {
  const Test1({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WelcomeScreen(),
    );
  }
}
