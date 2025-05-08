import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/auth_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final int userId = AuthProvider.currentUserId ?? 0;
    final url = Uri.parse('http://10.0.2.2:5000/notifications/$userId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          notifications = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        print("❌ Failed to load notifications");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("❌ Error: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Color(0xFF1F3A93),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : notifications.isEmpty
              ? Center(child: Text("No notifications found."))
              : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: ListTile(
                      leading: Icon(
                        Icons.notifications,
                        color: Color(0xFF1F3A93),
                      ),
                      title: Text(notif['message']),
                      subtitle: Text("At ${notif['timestamp']}"),
                    ),
                  );
                },
              ),
    );
  }
}
