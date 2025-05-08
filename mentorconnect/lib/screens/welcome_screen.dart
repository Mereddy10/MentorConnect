import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final Color themeColor = const Color(0xFF1F3A93);

  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Larger diagonal background (behind)
          ClipPath(
            clipper: DiagonalClipper1(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    themeColor.withOpacity(0.5),
                    themeColor.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Smaller diagonal foreground
          ClipPath(
            clipper: DiagonalClipper2(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [themeColor, themeColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Main content in the center
          Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // White card to hold icon, text, and buttons
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Replace with your own logo/image
                        Icon(Icons.school, size: 80, color: themeColor),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          'Welcome to Mentor Connect',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtitle / description
                        Text(
                          'Join now and connect with mentors\nto enhance your learning experience.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Register button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 40,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Register',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Login button (Outlined for contrast)
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: themeColor,
                            side: BorderSide(color: themeColor),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 40,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Larger diagonal shape behind
class DiagonalClipper1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Start at top-left
    path.lineTo(0, size.height * 0.8);

    // Diagonal line to (width, height * 0.6)
    path.lineTo(size.width, size.height * 0.6);

    // Close path at the top-right corner
    path.lineTo(size.width, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(DiagonalClipper1 oldClipper) => false;
}

/// Smaller diagonal shape in front
class DiagonalClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Start at top-left
    path.lineTo(0, size.height * 0.7);

    // Diagonal line to (width, height * 0.5)
    path.lineTo(size.width, size.height * 0.5);

    // Close path at the top-right corner
    path.lineTo(size.width, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(DiagonalClipper2 oldClipper) => false;
}