import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pay_ready/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:pay_ready/screens/home_screen.dart';
import 'package:pay_ready/screens/login_screen.dart';
import 'package:pay_ready/screens/verification_screen.dart';
import 'package:pay_ready/widgets/custom_scaffold.dart';
import 'verification_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;

  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
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
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hintText: 'Enter Full Name',
                        validator: 'Please enter your full name',
                      ),
                      const SizedBox(height: 25.0),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hintText: 'Enter Phone Number',
                        validator: 'Please enter a valid phone number',
                        prefixText: '+966',
                        keyboardType: TextInputType.phone,
                        fieldType: 'phone',
                      ),
                      const SizedBox(height: 25.0),
                      _buildTextField(
                        controller: _usernameController,
                        label: 'Username',
                        hintText: 'Enter Username',
                        validator: 'Please enter a username',
                      ),
                      const SizedBox(height: 25.0),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        hintText: 'Enter Email',
                        validator: 'Please enter a valid email',
                        fieldType: 'email',
                      ),
                      const SizedBox(height: 25.0),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hintText: 'Enter Password',
                        validator: 'Please enter a password',
                        obscureText: true,
                      ),
                      const SizedBox(height: 25.0),
                      Row(
                        children: [
                          Checkbox(
                            value: agreePersonalData,
                            onChanged: (bool? value) {
                              setState(() {
                                agreePersonalData = value!;
                              });
                            },
                          ),
                          const Text('I agree to the processing of Personal data'),
                        ],
                      ),
                      const SizedBox(height: 25.0),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                          onPressed: _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, 
                            side: const BorderSide(color: Colors.black, width: 1), 
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(33), 
                            ),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.black, // Set text color directly
                            ),
                            ),
                        ),
                        ),
                      const SizedBox(height: 30.0),
                      _buildSocialIcons(),
                      const SizedBox(height: 25.0),
                      _buildAlreadyHaveAccount(),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
    String? fieldType,
  }) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validator;
        }
        // Phone validation
        if (fieldType == 'phone' && value.length != 9) {
          return 'Phone number must be exactly 9 digits';
        }
        // Email validation
        if (fieldType == 'email' &&
            !RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixText: prefixText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildSocialIcons() {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black, // Black background
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: () async {
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
  );
}


  Widget _buildAlreadyHaveAccount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Already have an account? '),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          child: const Text(
            'Log in',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ),
      ],
    );
  }

 Future<void> _signUp() async {
  if (_formSignupKey.currentState!.validate() && agreePersonalData) {
    try {
      // Sign up the user with email and password
      User? user = await _auth.signUpWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        // Store additional user information in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'username': _usernameController.text,
          'email': user.email,
          'points': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Navigate to VerificationScreen with the email as contactInfo
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationScreen(
              contactInfo: _emailController.text,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-up failed: $e')),
      );
    }
  } else if (!agreePersonalData) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please agree to the processing of personal data")),
    );
  }
}

}
