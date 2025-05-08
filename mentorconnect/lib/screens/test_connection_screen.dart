/*import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TestConnectionScreen extends StatefulWidget {
  @override
  _TestConnectionScreenState createState() => _TestConnectionScreenState();
}

class _TestConnectionScreenState extends State<TestConnectionScreen> {
  String _message = '';

  Future<void> testConnection() async {
    try {
      final res = await http.get(
        Uri.parse('http://10.0.2.2:5000/auth/register'),
      );
      setState(() {
        _message = "✅ Success: ${res.statusCode}";
      });
    } catch (e) {
      setState(() {
        _message = "❌ Failed: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Test Connection")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: testConnection,
              child: Text("Test Flask Connection"),
            ),
            SizedBox(height: 20),
            Text(_message, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
*/