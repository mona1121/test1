import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pay_ready/screens/home_screen.dart';
import 'package:pay_ready/screens/welcome_screen.dart';
import 'package:go_sell_sdk_flutter/go_sell_sdk_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized
  await Firebase.initializeApp();  // Initialize Firebase

WidgetsFlutterBinding.ensureInitialized();
  await GoSellSdkFlutter.init(
    publicKey: 'pk_test_Ucvnrkb2RpSI1uD34W6NZsFJ', 
    secretKey: 'sk_test_AiEpUqHlcPgj28msDFIvRK7G', 
    sandboxMode: true
  );
  runApp(const PayReady());  // Run the main app
}

class PayReady extends StatelessWidget {
  const PayReady({super.key});

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
