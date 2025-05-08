import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/auth_provider.dart';

class StudentMeetingsScreen extends StatefulWidget {
  const StudentMeetingsScreen({super.key});

  @override
  _StudentMeetingsScreenState createState() => _StudentMeetingsScreenState();
}

class _StudentMeetingsScreenState extends State<StudentMeetingsScreen> {
  List<dynamic> meetings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMeetings();
  }

  Future<void> fetchMeetings() async {
    final int studentId = AuthProvider.currentUserId ?? 0;
    final url = Uri.parse('http://10.0.2.2:5000/meeting/student/$studentId');

    try {
      final response = await http.get(
        url,
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          meetings = data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Meetings', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1F3A93),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : meetings.isEmpty
              ? Center(
                child: Text(
                  "No meetings found.",
                  style: TextStyle(fontSize: 16),
                ),
              )
              : ListView.builder(
                itemCount: meetings.length,
                itemBuilder: (context, index) {
                  final meeting = meetings[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Faculty: ${meeting['faculty_name']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Date: ${meeting['date']}'),
                              Text('Time: ${meeting['time']}'),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Status: ${meeting['status']}',
                            style: TextStyle(
                              color:
                                  meeting['status'] == 'Accepted'
                                      ? Colors.green
                                      : meeting['status'] == 'Rejected'
                                      ? Colors.red
                                      : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (meeting['status'] == 'Postponed' &&
                              meeting['new_time'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text('New Time: ${meeting['new_time']}'),
                            ),
                          if (meeting['mode'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text('Mode: ${meeting['mode']}'),
                            ),
                          if (meeting['feedback'] != null &&
                              meeting['feedback'].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Faculty Feedback: ${meeting['feedback']}',
                                style: TextStyle(color: Colors.blueGrey),
                              ),
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
