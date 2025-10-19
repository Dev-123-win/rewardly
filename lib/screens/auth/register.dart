import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart'; // Import HugeIcons
import '../../auth_service.dart';
import 'sign_in.dart';
import '../../widgets/custom_button.dart';
import '../info/terms_of_service_screen.dart';
import '../info/privacy_policy_screen.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  const Register({super.key, required this.toggleView});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = '';
  String password = '';
  String referralCode = '';
  String error = '';
  bool _agreedToTerms = false;

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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 40),
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join thousands earning with our platform',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 40),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedMail01, color: Colors.grey), // Replaced Icon with HugeIcon
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
                              prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedLocker01, color: Colors.grey), // Replaced Icon with HugeIcon
                              hintText: 'Create a strong password',
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
                          const SizedBox(height: 20.0),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Referral Code (Optional)',
                              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedUser, color: Colors.grey), // Replaced Icon with HugeIcon
                              hintText: 'Enter referral code if you have one',
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
                            onChanged: (val) {
                              setState(() => referralCode = val);
                            },
                          ),
                          const SizedBox(height: 10.0),
                          Row(
                            children: [
                              HugeIcon(icon: HugeIcons.strokeRoundedInformationCircle, color: Colors.orange, size: 18), // Replaced Icon with HugeIcon
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Using a referral code gives you and your friend bonus credits',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.orange.shade700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _agreedToTerms,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    _agreedToTerms = newValue ?? false;
                                  });
                                },
                                activeColor: const Color(0xFF6200EE), // Deep purple
                              ),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    text: 'I agree to the ',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6200EE), decoration: TextDecoration.underline),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()),
                                            );
                                          },
                                      ),
                                      TextSpan(
                                        text: ' and ',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                                      ),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6200EE), decoration: TextDecoration.underline),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                                            );
                                          },
                                      ),
                                      TextSpan(
                                        text: '. I confirm that I am at least 18 Years old.',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          CustomButton(
                            text: 'Create Account',
                            width: double.infinity,
                            hugeIcon: HugeIcons.strokeRoundedUserAdd01, // Replaced icon with hugeIcon
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (!_agreedToTerms) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('You must agree to the Terms & Conditions and Privacy Policy and confirm you are 18+', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
                                      backgroundColor: Theme.of(context).colorScheme.error,
                                    ),
                                  );
                                  return;
                                }
                                setState(() => loading = true);
                                final scaffoldMessenger = ScaffoldMessenger.of(context);
                                final theme = Theme.of(context);
                                dynamic authResult = await _auth.registerWithEmailAndPassword(email, password, referralCode: referralCode.isEmpty ? null : referralCode);
                                if (!mounted) return;

                                if (!authResult.success) {
                                  setState(() {
                                    loading = false;
                                    error = authResult.message;
                                  });
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(error, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
                                      backgroundColor: theme.colorScheme.error,
                                    ),
                                  );
                                } else {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text('Registration successful! Please log in.', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
                                      backgroundColor: const Color(0xFF6200EE), // Deep purple for success
                                    ),
                                  );
                                  widget.toggleView();
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
