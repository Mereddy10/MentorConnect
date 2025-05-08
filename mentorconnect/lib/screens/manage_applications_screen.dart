import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';

class ManageApplicationsScreen extends StatefulWidget {
  const ManageApplicationsScreen({super.key});

  @override
  _ManageApplicationsScreenState createState() =>
      _ManageApplicationsScreenState();
}

class _ManageApplicationsScreenState extends State<ManageApplicationsScreen> {
  List<Map<String, dynamic>> applications = [];
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
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          applications =
              data.map((item) {
                return {
                  'id': item['app_id'],
                  'student': item['student_name'],
                  'project': item['project_title'],
                  'status': item['status'],
                  'feedback': item['feedback'],
                  'pdf_url': item['pdf_url'],
                };
              }).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        print('❌ Failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('❌ Error: $e');
    }
  }

  Future<void> openPdfUrl(String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("No document submitted.")));
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Could not launch PDF.")));
    }
  }

  Future<void> submitReview(
    int index,
    String status, [
    String feedback = "",
  ]) async {
    final int facultyId = AuthProvider.currentUserId ?? 0;
    final url = Uri.parse(
      'http://10.0.2.2:5000/application/review/faculty/$facultyId',
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "id": applications[index]['id'],
        "status": status,
        "feedback": feedback,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        applications[index]['status'] = status;
        if (feedback.isNotEmpty) applications[index]['feedback'] = feedback;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("✅ Updated")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Update failed")));
    }
  }

  void _provideFeedback(int index) {
    TextEditingController feedbackController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Provide Feedback'),
            content: TextField(
              controller: feedbackController,
              decoration: InputDecoration(labelText: 'Feedback'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  submitReview(
                    index,
                    applications[index]['status'],
                    feedbackController.text,
                  );
                },
                child: Text('Submit'),
              ),
            ],
          ),
    );
  }

  void _updateApplicationStatus(int index, String status) {
    submitReview(index, status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text(
          'Manage Applications',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF1F3A93),
        centerTitle: true,
        elevation: 4,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : applications.isEmpty
              ? Center(child: Text("No applications found."))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: applications.length,
                itemBuilder: (context, index) => _buildApplicationCard(index),
              ),
    );
  }

  Widget _buildApplicationCard(int index) {
    final app = applications[index];
    Color statusColor =
        app['status'] == 'Approved'
            ? Colors.green
            : app['status'] == 'Rejected'
            ? Colors.red
            : Colors.orange;

    final bool isFinalized =
        app['status'] == 'Approved' || app['status'] == 'Rejected';

    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow("Student", app['student'], isBold: true),
            SizedBox(height: 6),
            _infoRow("Project", app['project']),
            SizedBox(height: 6),
            _infoRow("Status", app['status'], valueColor: statusColor),
            if (app['feedback'] != null &&
                app['feedback'].toString().isNotEmpty)
              _infoRow("Feedback", app['feedback']),
            if (app['pdf_url'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: GestureDetector(
                  onTap: () => openPdfUrl(app['pdf_url']),
                  child: Text(
                    "📄 View Statement",
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            SizedBox(height: 14),
            isFinalized
                ? Text(
                  '✅ Response submitted.',
                  style: TextStyle(color: Colors.grey[700]),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed:
                          () => _updateApplicationStatus(index, 'Approved'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                      child: Text("Approve"),
                    ),
                    SizedBox(width: 8),
                    OutlinedButton(
                      onPressed:
                          () => _updateApplicationStatus(index, 'Rejected'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: Text("Reject"),
                    ),
                    SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _provideFeedback(index),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF1F3A93),
                      ),
                      child: Text("Feedback"),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 85,
          child: Text(
            "$label:",
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.black,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
