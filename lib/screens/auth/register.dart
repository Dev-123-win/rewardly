import 'package:flutter/material.dart';
import '../../auth_service.dart';
import 'sign_in.dart';
import '../../widgets/custom_button.dart';
import 'auth_card.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  const Register({super.key, required this.toggleView});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>(); // Corrected type here
  bool loading = false;

  String email = '';
  String password = '';
  String referralCode = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading
        ? const AuthScreenLoading()
        : Scaffold(
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
                                validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                                onChanged: (val) {
                                  setState(() => email = val);
                                },
                              ),
                              const SizedBox(height: 20.0),
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                                  prefixIcon: Icon(Icons.lock, color: Colors.grey[700]),
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
                                obscureText: true,
                                validator: (val) => val!.length < 6 ? 'Enter a password 6+ chars long' : null,
                                onChanged: (val) {
                                  setState(() => password = val);
                                },
                              ),
                              const SizedBox(height: 20.0),
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Referral Code (Optional)',
                                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                                  prefixIcon: Icon(Icons.person_add, color: Colors.grey[700]),
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
                                onChanged: (val) {
                                  setState(() => referralCode = val);
                                },
                              ),
                              const SizedBox(height: 30.0),
                              CustomButton(
                                text: 'Register',
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => loading = true);
                                    final scaffoldMessenger = ScaffoldMessenger.of(context);
									final theme = Theme.of(context);
                                    dynamic authResult = await _auth.registerWithEmailAndPassword(email, password, referralCode: referralCode.isEmpty ? null : referralCode);
                                    if (!mounted) return;

                                    if (!authResult.success) {
                                      setState(() {
                                        loading = false;
                                        error = authResult.message; // Set the error message from AuthResult
                                      });
                                      scaffoldMessenger.showSnackBar(
                                        SnackBar(
                                          content: Text(error, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    } else {
                                      // Registration successful
                                      scaffoldMessenger.showSnackBar(
                                        SnackBar(
                                          content: Text('Registration successful! Please log in.', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      widget.toggleView(); // Navigate to sign-in view
                                    }
                                  }
                                },
                              ),
                              const SizedBox(height: 20.0),
                              TextButton(
                                onPressed: () {
                                  widget.toggleView();
                                },
                                child: Text(
                                  'Already have an account? Login now',
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
