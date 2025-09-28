import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rewardly_app/widgets/custom_button.dart';
import 'package:rewardly_app/screens/auth/auth_card.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white, // Solid white background
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/AppLogo.png', height: 100), // App Logo
                const SizedBox(height: 20),
                Text(
                  'Earn Smarter. Play. Win. Cashout.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                AuthCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                            prefixIcon: Icon(Icons.email, color: Colors.grey[700]),
                            filled: true,
                            fillColor: Colors.grey[100],
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black87),
                          validator: (val) => val!.isEmpty ? 'Enter your email' : null,
                          onChanged: (val) {
                            setState(() => email = val);
                          },
                        ),
                        const SizedBox(height: 30.0),
                        loading
                            ? CircularProgressIndicator(color: Theme.of(context).primaryColor)
                            : CustomButton(
                                text: 'Send Reset Link',
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => loading = true);
                                    String? errorMessage;
                                    bool success = false;

                                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                                    final navigator = Navigator.of(context);
                                    final theme = Theme.of(context);

                                    try {
                                      await _auth.sendPasswordResetEmail(email: email);
                                      success = true;
                                    } on FirebaseAuthException catch (e) {
                                      errorMessage = e.message ?? 'An unknown error occurred.';
                                    } catch (e) {
                                      errorMessage = 'An unexpected error occurred.';
                                    }

                                    if (!mounted) return;

                                    setState(() {
                                      loading = false;
                                      if (errorMessage != null) {
                                        error = errorMessage;
                                      }
                                    });

                                    if (success) {
                                      scaffoldMessenger.showSnackBar(SnackBar(
                                        content: Text('Password reset link sent to $email'),
                                        backgroundColor: Colors.green,
                                      ));
                                      navigator.pop();
                                    } else if (errorMessage != null) {
                                      scaffoldMessenger.showSnackBar(SnackBar(
                                          content: Text(errorMessage, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
                                          backgroundColor: Colors.red));
                                    }
                                  }
                                },
                              ),
                        const SizedBox(height: 20.0),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Back to Sign In',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).primaryColor, decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
