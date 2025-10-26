import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart'; // Import HugeIcons
//import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart'; // Import lottie package
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
  void dispose() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Dismiss any active snackbar
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const AuthScreenLoading()
        : SafeArea(
            child: Scaffold(
              backgroundColor: Colors.white, // Plain white background
              body: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final isLargeScreen = screenWidth > 800; // Define what constitutes a "large screen"

                  return Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isLargeScreen ? constraints.maxWidth * 0.2 : 20.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: isLargeScreen ? 80 : 40),
                          Text(
                            'Welcome Back',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isLargeScreen ? 36 : 28,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to your account to continue',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey.shade600,
                                  fontSize: isLargeScreen ? 18 : 16,
                                ),
                          ),
                          SizedBox(height: isLargeScreen ? 60 : 40),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Email Address',
                                    labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                    prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedMail01, color: Colors.grey, size: 30.0),
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
                                const SizedBox(height: 20.0),
                                TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                    prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedSquareLock01, color: Colors.grey, size: 30.0),
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
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6200EE)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                                CustomButton(
                                  text: 'Login to Your Account',
                                  width: double.infinity,
                                  hugeIcon: HugeIcons.strokeRoundedArrowRight01,
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
                  );
                },
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
          child: Padding( // Added Padding for better UI
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/AppLogo.png',
                  height: 150,
                  width: 150,
                  fit: BoxFit.contain,
                ), // Increased logo size
                const SizedBox(height: 40), // Increased spacing
                Text(
                  'Loading Rewardly...',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold, // Made text bold
                      ),
                ),
                const SizedBox(height: 20), // Spacing between text and animation
                Lottie.asset(
                  'assets/lottie/sand glass loading animation.json', // New Lottie animation
                  width: 200, // Adjusted size
                  height: 200, // Adjusted size
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
