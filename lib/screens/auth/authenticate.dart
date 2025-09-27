import 'package:flutter/material.dart';
import 'package:rewardly_app/screens/auth/sign_in.dart';
import 'package:rewardly_app/screens/auth/register.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;

  void toggleView() {
    setState(() {
      showSignIn = !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white, // Solid white background
        ),
        child: Column(
          children: [
            const SizedBox(height: 80), // Space for logo and tagline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100], // Light grey background for the segmented control
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey[300]!), // Subtle border
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showSignIn = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          decoration: BoxDecoration(
                            color: showSignIn ? Theme.of(context).primaryColor : Colors.transparent, // Primary color for selected
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: showSignIn ? Colors.white : Colors.black87, // White text for selected, dark for unselected
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showSignIn = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          decoration: BoxDecoration(
                            color: !showSignIn ? Theme.of(context).primaryColor : Colors.transparent, // Primary color for selected
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            child: Text(
                              'Register',
                              style: TextStyle(
                                color: !showSignIn ? Colors.white : Colors.black87, // White text for selected, dark for unselected
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: showSignIn
                  ? SignIn(toggleView: toggleView)
                  : Register(toggleView: toggleView),
            ),
          ],
        ),
      ),
    );
  }
}
