import 'package:flutter/material.dart';
import '../../auth_service.dart'; // Use AuthService
import '../../widgets/custom_button.dart';
import '../../models/auth_result.dart'; // Import AuthResult

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final AuthService _auth = AuthService(); // Use AuthService
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white, // Plain white background
        body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 40),
              Text(
                'Reset Password',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your email and we\'ll send you a reset link',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                        hintText: 'Enter your email',
                        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF6200EE), width: 1.5),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1.5),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black87),
                      validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                      onChanged: (val) {
                        setState(() => email = val);
                      },
                    ),
                    const SizedBox(height: 30.0),
                    loading
                        ? CircularProgressIndicator(color: const Color(0xFF6200EE))
                        : CustomButton(
                            text: 'Send Reset Link',
                            width: double.infinity,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => loading = true);
                                AuthResult authResult = await _auth.sendPasswordResetEmail(email);
                                if (!mounted) return;

                                setState(() {
                                  loading = false;
                                  if (!authResult.success) {
                                    error = authResult.message ?? 'An unknown error occurred.';
                                  } else {
                                    error = 'Password reset email sent to $email';
                                  }
                                });

                                if (!mounted) return; // Check mounted again before using context
                                final scaffoldMessenger = ScaffoldMessenger.of(context);
                                final theme = Theme.of(context);

                                if (authResult.success) {
                                  scaffoldMessenger.showSnackBar(SnackBar(
                                    content: Text('Password reset link sent to $email', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
                                    backgroundColor: const Color(0xFF6200EE),
                                  ));
                                  if (!mounted) return; // Check mounted again before using context
                                  Navigator.pop(context);
                                } else {
                                  scaffoldMessenger.showSnackBar(SnackBar(
                                      content: Text(error, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
                                      backgroundColor: theme.colorScheme.error));
                                }
                              }
                            },
                          ),
                    const SizedBox(height: 20.0),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, color: Colors.grey.shade600, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Back to Sign In',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
