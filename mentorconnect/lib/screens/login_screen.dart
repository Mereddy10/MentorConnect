import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'register_screen.dart';
import 'package:mentorconnect/screens/dashboard_screen.dart';

import 'faculty_dashboard.dart';
import '../providers/auth_provider.dart'; // ✅ Import your AuthProvider

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedRole;
  final Color themeColor = const Color(0xFF1F3A93);

  void _loginUser() async {
    print("🔐 Login button pressed");

    if (_formKey.currentState!.validate() && _selectedRole != null) {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:5000/auth/login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
          'role': _selectedRole?.toLowerCase(),
        }),
      );

      print("📥 Status: ${response.statusCode}");
      print("📦 Body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final int userId = data['user_id']; // ✅ FIXED
        AuthProvider.currentUserId = userId;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login success! User ID = $userId')),
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    _selectedRole == 'Student'
                        ? DashboardScreen()
                        : FacultyDashboardScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed: ${data['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a role'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [themeColor, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                elevation: 6.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                          ),
                        ),
                        SizedBox(height: 24),
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: InputDecoration(
                            labelText: 'Select Role',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              ['Student', 'Faculty']
                                  .map(
                                    (role) => DropdownMenuItem(
                                      value: role,
                                      child: Text(role),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (value) => setState(() => _selectedRole = value),
                          validator:
                              (value) =>
                                  value == null ? 'Please select a role' : null,
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value == null || !value.contains('@')
                                      ? 'Enter a valid email'
                                      : null,
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.length < 6
                                      ? 'Password too short'
                                      : null,
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loginUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        TextButton(
                          onPressed:
                              () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RegisterScreen(),
                                ),
                              ),
                          child: Text(
                            'Not registered? Register',
                            style: TextStyle(color: themeColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
