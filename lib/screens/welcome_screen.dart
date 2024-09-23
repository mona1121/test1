import 'package:flutter/material.dart';
import 'package:test1/screens/login_screen.dart';
import 'package:test1/screens/signup_screen.dart';
import 'package:test1/widgets/custom_scaffold.dart';
import 'package:test1/widgets/welcome_button.dart';

class WelcomeScreen extends StatelessWidget{
  const WelcomeScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
            flex: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 40.0,
                ),
             child: Center(
                 child: RichText(
                     textAlign: TextAlign.center,
                     text: const TextSpan(
                       children: [
                         TextSpan(
                             text: 'Pay-Ready\n',
                             style: TextStyle(
                               fontFamily: 'LeagueSpartan',
                               fontSize: 65.0,
                               fontWeight: FontWeight.w600,
                             )),
                         TextSpan(
                           text: '\nEnhance Your Shopping Experience',
                           style: TextStyle(
                             fontSize: 20,
                             //height: 0,
                           )
                         )
                       ]
                     ),)),
          )),

          const Flexible(
            flex: 2,
            child: Row(
              children: [
               Expanded(
                 child: WelcomeButton(
                   buttonText: 'Sign up',
                   onTap: SignupScreen(),
                   color: Colors.transparent,
                   textColor: Colors.white,
                 ),
               ),
               Expanded(
                 child: WelcomeButton(
                   buttonText: 'Log in',
                   onTap: LoginScreen(),
                   color: Colors.white,
                   textColor: Colors.black,
                 ),
               ),
              ],
            ),
          ),
        ],
      ),
    );

  }

}