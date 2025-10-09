import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../auth_service.dart';
import '../../widgets/custom_button.dart';
import 'forgot_password.dart';
import '../../models/auth_result.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  const SignIn({super.key, required this.toggleView});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading
        ? const AuthScreenLoading()
        : SafeArea(
            child: Scaffold(
              backgroundColor: Colors.white, // Plain white background
              body: Center(
                child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start, // Align to start for title
                  crossAxisAlignment: CrossAxisAlignment.start, // Align to start for title
                  children: <Widget>[
                    const SizedBox(height: 40), // Spacing from top
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to your account to continue',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 40), // Spacing before form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey), // Outline icon
                              hintText: 'Enter your email',
                              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade400),
                              filled: true,
                              fillColor: Colors.grey.shade100, // Light grey fill
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Color(0xFF6200EE), width: 1.5), // Deep purple for focused
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
                          const SizedBox(height: 20.0),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey), // Outline icon
                              hintText: 'Enter your password',
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
                            obscureText: true,
                            validator: (val) => val!.length < 6 ? 'Enter a password 6+ chars long' : null,
                            onChanged: (val) {
                              setState(() => password = val);
                            },
                          ),
                          const SizedBox(height: 10.0),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ForgotPassword()),
                                );
                              },
                              child: Text(
                                'Forgot Password?',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6200EE)), // Deep purple
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          CustomButton(
                            text: 'Login to Your Account',
                            width: double.infinity,
                            icon: Icons.arrow_forward, // Add arrow icon
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => loading = true);
                                final scaffoldMessenger = ScaffoldMessenger.of(context);
                                final theme = Theme.of(context);
                                AuthResult authResult = await _auth.signInWithEmailAndPassword(email, password);
                                if (!mounted) return;

                                if (!authResult.success) {
                                  setState(() {
                                    loading = false;
                                    error = authResult.message ?? 'An unknown error occurred.';
                                  });
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(error, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
                                      backgroundColor: theme.colorScheme.error,
                                    ),
                                  );
                                } else {
                                  setState(() {
                                    loading = false;
                                    error = '';
                                  });
                                }
                              }
                            },
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

class AuthScreenLoading extends StatelessWidget {
  const AuthScreenLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white, // Use white background for loading
        body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/AppLogo.png', height: 120),
            const SizedBox(height: 30),
            Text(
              'Loading Rewardly...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 40),
            LoadingAnimationWidget.horizontalRotatingDots(
              color: const Color(0xFF6200EE), // Deep purple for animation
              size: 50,
            ),
          ],
        ),
      ),
    ));
  }
}
