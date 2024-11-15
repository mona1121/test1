import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/custom_scaffold.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<ContactUs> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // Function to handle "Send" button press
  Future<void> _sendEmail() async {
  if (_formKey.currentState!.validate()) {
    final email = _emailController.text;
    final title = _titleController.text;
    final content = _contentController.text;

    final uri = Uri(
      scheme: 'mailto',
      path: 'moi20inao@gmail.com',
      queryParameters: {
        'subject': title,
        'body': 'From: $email\n\n$content',
      },
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No email client installed or unable to open email client')),
      );
    }
  }
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
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Contact Us',
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Email TextField
                        TextFormField(
                          controller: _emailController,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter your email'
                              : null,
                          decoration: InputDecoration(
                            label: const Text('Email'),
                            hintText: 'Enter your email',
                            hintStyle: const TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Title TextField
                        TextFormField(
                          controller: _titleController,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter a title'
                              : null,
                          decoration: InputDecoration(
                            label: const Text('Title'),
                            hintText: 'Enter the title of your message',
                            hintStyle: const TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Content TextField (Multi-line)
                        TextFormField(
                          controller: _contentController,
                          maxLines: 6, // Multi-line input
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter your message'
                              : null,
                          decoration: InputDecoration(
                            label: const Text('Content'),
                            hintText: 'Write your message here',
                            hintStyle: const TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Send Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _sendEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black, // Black background
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(33),
                              ),
                            ),
                            child: const Text(
                              'Send',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
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
}
