import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pay_ready/widgets/custom_scaffold.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formEditProfileKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controllers for profile fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Controllers for password fields
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _reenterPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _reenterPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formEditProfileKey.currentState!.validate()) {
      final user = _auth.currentUser;

      if (user != null) {
        try {
          // Update profile information in Firestore
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'name': _nameController.text,
            'email': _emailController.text,
            'phone': _phoneController.text,
          });

          // Update email in Firebase Auth
          await user.updateEmail(_emailController.text);

          // Change password if fields are filled
          if (_newPasswordController.text.isNotEmpty && _reenterPasswordController.text.isNotEmpty) {
            if (_newPasswordController.text == _reenterPasswordController.text) {
              final credential = EmailAuthProvider.credential(
                email: user.email!,
                password: _oldPasswordController.text,
              );

              // Reauthenticate the user
              await user.reauthenticateWithCredential(credential);
              await user.updatePassword(_newPasswordController.text);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile and password updated successfully")),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("New passwords do not match")),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Profile updated successfully")),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error updating profile: ${e.toString()}")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(flex: 1, child: SizedBox(height: 10)),
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
                  key: _formEditProfileKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Edit Profile',
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 40),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hintText: 'Enter Full Name',
                        validator: 'Please enter your full name',
                      ),
                      const SizedBox(height: 25),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        hintText: 'Enter Email',
                        validator: 'Please enter a valid email',
                        fieldType: 'email',
                      ),
                      const SizedBox(height: 25),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hintText: 'Enter Phone Number',
                        prefixText: '+966',
                        keyboardType: TextInputType.phone,
                        validator: 'Please enter a valid phone number',
                        fieldType: 'phone',
                      ),
                      const Divider(height: 50, thickness: 1),
                      const Text('Password Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _oldPasswordController,
                        label: 'Old Password',
                        hintText: 'Enter Old Password',
                        obscureText: true, validator: '',
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _newPasswordController,
                        label: 'New Password',
                        hintText: 'Enter New Password',
                        obscureText: true, validator: '',
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _reenterPasswordController,
                        label: 'Re-enter New Password',
                        hintText: 'Re-enter New Password',
                        obscureText: true, validator: '',
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(33),
                            ),
                          ),
                          child: const Text('Update', style: TextStyle(color: Colors.white)),
                        ),
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
        if (value == null || value.isEmpty) return validator;
        if (fieldType == 'phone' && value.length != 9) return 'Phone number must be exactly 9 digits';
        if (fieldType == 'email' && !RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
