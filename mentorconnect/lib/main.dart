import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/welcome_screen.dart';

// Make sure path is correct

void main() {
  runApp(MentorConnect()); // not MentorConnect
}

class MentorConnect extends StatelessWidget {
  const MentorConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mentor Connect',
        theme: ThemeData.light(),
        home: WelcomeScreen(),
      ),
    );
  }
}
