import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For limiting input to digits
import 'package:test1/widgets/custom_scaffold.dart'; // Assuming this exists for consistent page layout

class VerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const VerificationScreen({super.key, required this.phoneNumber});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _otpKey = GlobalKey<FormState>();
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());

  @override
  void dispose() {
    // Dispose all controllers when widget is disposed
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onOtpChange(int index, String value) {
    if (value.length == 1 && index < 5) {
      // Automatically move to the next field if a digit is entered
      FocusScope.of(context).nextFocus();
    } else if (value.isEmpty && index > 0) {
      // Automatically move to the previous field if a digit is deleted
      FocusScope.of(context).previousFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              height: 10,
            ),
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
                  key: _otpKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // OTP Verification title
                      const Text(
                        'OTP Verification',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      // Instruction text
                      Text(
                        'Enter the OTP sent to ${widget.phoneNumber}',
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      // OTP input fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 45,
                            height: 55,
                            child: TextFormField(
                              controller: _otpControllers[index],
                              autofocus: index == 0, // Focus on the first box initially
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 24.0),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly, // Only allow digits
                              ],
                              decoration: InputDecoration(
                                counterText: '', // Hide character counter
                                
                                hintStyle: const TextStyle(color: Colors.black26),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Colors.black12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Colors.black12),
                                ),
                              ),
                              onChanged: (value) => _onOtpChange(index, value),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '';
                                }
                                return null;
                              },
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 40.0),
                      // Verify button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_otpKey.currentState!.validate()) {
                              String otp = _otpControllers
                                  .map((controller) => controller.text)
                                  .join(); // Collect OTP from each box
                              if (otp.length == 6) {
                                // Process OTP verification
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Verifying OTP...')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter the complete OTP')),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text('Verify'),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      // Resend OTP link
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Resending OTP...')),
                          );
                        },
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
}
