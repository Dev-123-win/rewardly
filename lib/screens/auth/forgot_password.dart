import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart'; // Import HugeIcons
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
  void dispose() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Dismiss any active snackbar
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white, // Plain white background
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isLargeScreen = screenWidth > 800;
            final horizontalPadding = isLargeScreen ? constraints.maxWidth * 0.2 : 20.0;
            final titleFontSize = isLargeScreen ? 36.0 : 28.0;
            final descriptionFontSize = isLargeScreen ? 18.0 : 16.0;
            final topSpacing = isLargeScreen ? 80.0 : 40.0;
            final formSpacing = isLargeScreen ? 60.0 : 40.0;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: topSpacing),
                    Text(
                      'Reset Password',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: titleFontSize,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your email and we\'ll send you a reset link',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade600,
                            fontSize: descriptionFontSize,
                          ),
                    ),
                    SizedBox(height: formSpacing),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedMail01, color: Colors.grey, size: 24.0),
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

                                      final currentContext = context;
                                      final scaffoldMessenger = ScaffoldMessenger.of(currentContext);
                                      final theme = Theme.of(currentContext);

                                      AuthResult authResult = await _auth.sendPasswordResetEmail(email);

                                      if (!currentContext.mounted) {
                                        return;
                                      }

                                      setState(() {
                                        loading = false;
                                        if (!authResult.success) {
                                          error = authResult.message ?? 'An unknown error occurred.';
                                        } else {
                                          error = 'Password reset email sent to $email';
                                        }
                                      });

                                      if (authResult.success) {
                                        scaffoldMessenger.showSnackBar(SnackBar(
                                          content: Text('Password reset link sent to $email', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
                                          backgroundColor: const Color(0xFF6200EE),
                                        ));
                                        if (currentContext.mounted) {
                                          Navigator.pop(currentContext);
                                        }
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
                                HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: Colors.grey.shade600, size: 20),
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
            );
          },
        ),
      ),
    );
  }
}
