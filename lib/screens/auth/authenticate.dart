import 'package:flutter/material.dart';
import 'sign_in.dart';
import 'register.dart';

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
      backgroundColor: Colors.white, // Plain white background
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40), // Spacing from top
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white, // White background for the tab container
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey.shade300), // Light grey border
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          decoration: BoxDecoration(
                            color: showSignIn ? const Color(0xFF6200EE) : Colors.transparent, // Deep purple for selected
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: showSignIn ? Colors.white : Colors.grey.shade700, // White for selected, dark grey for unselected
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          decoration: BoxDecoration(
                            color: !showSignIn ? const Color(0xFF6200EE) : Colors.transparent, // Deep purple for selected
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            child: Text(
                              'Register',
                              style: TextStyle(
                                color: !showSignIn ? Colors.white : Colors.grey.shade700, // White for selected, dark grey for unselected
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
