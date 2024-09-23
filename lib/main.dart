import 'package:flutter/material.dart';
import 'package:test1/screens/welcome_screen.dart';

void main() {
  runApp(test1());
}

class test1 extends StatelessWidget {
  const test1 ({super.key});

  //root widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomeScreen(),
    );
  }
}
