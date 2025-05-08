import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart'; // ✅ Authenticated user

class FacultyAppliedProjectsScreen extends StatefulWidget {
  const FacultyAppliedProjectsScreen({super.key});

  @override
  _FacultyAppliedProjectsScreenState createState() =>
      _FacultyAppliedProjectsScreenState();
}

class _FacultyAppliedProjectsScreenState
    extends State<FacultyAppliedProjectsScreen> {
  List<dynamic> applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchApplications();
  }

  Future<void> fetchApplications() async {
    final int facultyId = AuthProvider.currentUserId ?? 0;
    final url = Uri.parse(
      'http://10.0.2.2:5000/application/faculty/$facultyId',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          applications = data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('❌ Exception: $e');
    }
  }

  Future<void> openPdfUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Applied Projects', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1F3A93),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : applications.isEmpty
              ? Center(child: Text("No student applications found."))
              : ListView.builder(
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  final app = applications[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: ListTile(
                      title: Text('${app['student_name']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Project: ${app['project_title']}'),
                          Text('Status: ${app['status']}'),
                          if (app['statement_url'] != null)
                            TextButton.icon(
                              onPressed: () => openPdfUrl(app['statement_url']),
                              icon: Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red,
                              ),
                              label: Text('View Statement'),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
