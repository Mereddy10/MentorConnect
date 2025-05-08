import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/auth_provider.dart'; // ✅ For faculty ID

class MyPostedProjectsScreen extends StatefulWidget {
  const MyPostedProjectsScreen({super.key});

  @override
  _MyPostedProjectsScreenState createState() => _MyPostedProjectsScreenState();
}

class _MyPostedProjectsScreenState extends State<MyPostedProjectsScreen> {
  List<dynamic> _projects = [];
  bool _isLoading = true;

  final Color themeColor = Color(0xFF1F3A93);

  @override
  void initState() {
    super.initState();
    fetchMyProjects();
  }

  Future<void> fetchMyProjects() async {
    final int facultyId = AuthProvider.currentUserId ?? 0;
    final url = Uri.parse('http://10.0.2.2:5000/project/all');

    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          _projects =
              data.where((proj) => proj['faculty_id'] == facultyId).toList();
          _isLoading = false;
        });
      } else {
        print("Failed to load projects: ${res.statusCode}");
        _isLoading = false;
      }
    } catch (e) {
      print("❌ Error: $e");
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "My Posted Projects",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: themeColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _projects.isEmpty
              ? Center(
                child: Text(
                  "No projects posted yet.",
                  style: TextStyle(fontSize: 16),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    final project = _projects[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project['title'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: themeColor,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              project['description'],
                              style: TextStyle(fontSize: 15),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: themeColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "Slots: ${project['slots']}",
                                    style: TextStyle(
                                      color: themeColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
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
