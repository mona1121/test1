import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pay_ready/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:pay_ready/screens/home_screen.dart';
import 'package:pay_ready/screens/login_screen.dart';
import 'package:pay_ready/screens/verification_screen.dart';
import 'package:pay_ready/widgets/custom_scaffold.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;

  // Declare controllers
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
                        validator: 'Please enter Full name',
                      ),
                      const SizedBox(height: 25.0),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hintText: 'Enter Phone Number',
                        validator: 'Please enter Phone Number',
                        prefixText: '+966',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 25.0),
                      _buildTextField(
                        controller: _usernameController,
                        label: 'Username',
                        hintText: 'Enter Username',
                        validator: 'Please enter Username',
                      ),
                      const SizedBox(height: 25.0),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        hintText: 'Enter Email',
                        validator: 'Please enter Email',
                      ),
                      const SizedBox(height: 25.0),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hintText: 'Enter Password',
                        validator: 'Please enter Password',
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
                          const Text(
                            'I agree to the processing of Personal data',
                          ),
                        ],
                      ),
                      const SizedBox(height: 25.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _signUp,
                          child: const Text('Sign up'),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      _buildSocialIcons(),
                      const SizedBox(height: 25.0),
                      _buildAlreadyHaveAccount(),
                      const SizedBox(height: 20.0),
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
  }) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validator;
        }
        return null;
      },
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        label: Text(label),
        hintText: hintText,
        prefixText: prefixText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildSocialIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        IconButton(
          icon: FaIcon(FontAwesomeIcons.facebookF),
          onPressed: null,
        ),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.twitter),
          onPressed: null,
        ),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.google),
          onPressed: null,
        ),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.apple),
          onPressed: null,
        ),
      ],
    );
  }

  Widget _buildAlreadyHaveAccount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(color: Colors.black45),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          },
          child: const Text(
            'Log in',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _signUp() async {
    if (_formSignupKey.currentState!.validate() && agreePersonalData) {
      try {
        // Sign up user and get the Firebase User
        User? user = await _auth.signUpWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
        );

        if (user != null) {
          // Add user details to Firestore
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'name': _nameController.text,
            'phone': _phoneController.text,
            'username': _usernameController.text,
            'email': user.email,
            'points': 0,  // Initialize reward points
            'createdAt': FieldValue.serverTimestamp(),
          });

          // Navigate to the VerificationScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        }
      } catch (e) {
        print("Error during sign-up: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign-up failed: ${e.toString()}")),
        );
      }
    } else if (!agreePersonalData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please agree to the processing of personal data")),
      );
    }
  }
}

