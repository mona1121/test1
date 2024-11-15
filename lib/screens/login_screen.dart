import 'package:flutter/material.dart';
import 'package:pay_ready/screens/signup_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pay_ready/firebase_auth_implementation/firebase_auth_services.dart';
import '../widgets/custom_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pay_ready/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formLoginKey = GlobalKey<FormState>();
  bool rememberPassword = true;
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
   // _checkIfUserIsLoggedIn();
  }

  // Future<void> _checkIfUserIsLoggedIn() async {
  //   User? user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => const HomeScreen()),
  //     );
  //   }
  // }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(height: 10),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formLoginKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Log in',
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter Email'
                              : null,
                          decoration: InputDecoration(
                            label: const Text('Email'),
                            hintText: 'Enter Email',
                            hintStyle: const TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          obscuringCharacter: '*',
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter Password'
                              : null,
                          decoration: InputDecoration(
                            label: const Text('Password'),
                            hintText: 'Enter Password',
                            hintStyle: const TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: rememberPassword,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      rememberPassword = value!;
                                    });
                                  },
                                  activeColor: Colors.blue,
                                ),
                                const Text(
                                  'Remember me',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => _forgotPassword(context), // Call the reset function here
                              child: const Text(
                                'Forget Password?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),                          
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                          onPressed: () async {
                            if (_formLoginKey.currentState!.validate()) {
                              await _logIn();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, 
                            side: const BorderSide(color: Colors.black, width: 1), 
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(33), 
                            ),
                          ),
                          child: const Text(
                            'Log in',
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.black, // Set text color directly
                            ),
                            ),
                        ),
                        ),
                        const SizedBox(height: 20),
                        
                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black, // Black background
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: ()  async {
                                  User? user = await _auth.signInWithGoogle();
                                    if (user != null) {
                                       Navigator.of(context).pushAndRemoveUntil(
                                         MaterialPageRoute(
                                           builder: (context) =>
                                               const HomeScreen()),
                                              (Route<dynamic> route) => false,
                                             );
                                            } else {
                                             ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                 content: Text("Google sign-in failed")),
                                             );
                                           }
                                         }, // Function to handle Google sign-in
                              icon: const FaIcon(
                                FontAwesomeIcons.google, // Google icon (uses colored version if available)
                                color: Colors.white
                              ),
                              label: const Text(
                                'Sign in with Google',
                                style: TextStyle(
                                  color: Colors.white, // White text
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Don\'t have an account?',
                              style: TextStyle(color: Colors.black45),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SignupScreen()),
                                );
                              },
                              child: const Text(
                                ' Sign up',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logIn() async {
    if (_formLoginKey.currentState!.validate()) {
      try {
        User? user = await _auth.logInWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
        );

        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login failed: Invalid credentials")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${e.toString()}")),
        );
      }
    }
  }

  void _forgotPassword(BuildContext context) async {
  String? email = await showDialog(
    context: context,
    builder: (context) {
      String tempEmail = "";
      return AlertDialog(
        title: const Text("Reset Password"),
        content: TextField(
          onChanged: (value) => tempEmail = value,
          decoration: const InputDecoration(
            hintText: "Enter your email",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, tempEmail),
            child: const Text("Submit"),
          ),
        ],
      );
    },
  );

  if (email != null && email.isNotEmpty) {
    try {
      await _auth.sendPasswordResetEmail(email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset email sent")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }
}

}
