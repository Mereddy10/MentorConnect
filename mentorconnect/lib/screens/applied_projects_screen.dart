import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';

class AppliedProjectsScreen extends StatefulWidget {
  const AppliedProjectsScreen({super.key});

  @override
  _AppliedProjectsScreenState createState() => _AppliedProjectsScreenState();
}

class _AppliedProjectsScreenState extends State<AppliedProjectsScreen> {
  List<Map<String, dynamic>> appliedProjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAppliedProjects();
  }

  Future<void> fetchAppliedProjects() async {
    final int studentId = AuthProvider.currentUserId ?? 0;
    // Replace with actual logged-in user ID
    final url = Uri.parse(
      'http://10.0.2.2:5000/application/student/$studentId',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          appliedProjects =
              data.map((item) {
                return {
                  'title': item['project_title'],
                  'status': item['status'],
                  'documents': [item['pdf_url'] ?? 'No document uploaded'],
                };
              }).toList();
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load applied projects");
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        _isLoading = false;
      });
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
              : appliedProjects.isEmpty
              ? Center(child: Text('No applied projects found.'))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: appliedProjects.length,
                  itemBuilder: (context, index) {
                    final project = appliedProjects[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          project['title'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F3A93),
                          ),
                        ),
                        subtitle: Text(
                          'Status: ${project['status']}',
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                project['status'] == 'Approved'
                                    ? Colors.green
                                    : Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black54,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ProjectDetailsScreen(project),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
    );
  }
}

class ProjectDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> project;

  const ProjectDetailsScreen(this.project, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project['title'], style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1F3A93),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: ${project['status']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        project['status'] == 'Approved'
                            ? Colors.green
                            : Colors.orange,
                  ),
                ),
                SizedBox(height: 15),
                Divider(),
                SizedBox(height: 10),
                Text(
                  'Documents:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ...(project['documents'] as List<dynamic>).map<Widget>(
                  (doc) => Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.file_present,
                        color: Color(0xFF1F3A93),
                      ),
                      title: Text(doc),
                      trailing: Icon(Icons.download, color: Colors.black54),
                      onTap: () async {
                        if (doc != 'No document uploaded') {
                          final uri = Uri.parse(doc);
                          if (await canLaunchUrl(uri)) {
                            final launched = await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                            if (!launched) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("⚠️ Failed to open PDF"),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("⚠️ Invalid PDF URL")),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("❌ No document uploaded")),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
