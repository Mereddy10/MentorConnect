import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'student_meetings_screen.dart';
import '../providers/auth_provider.dart';

class ScheduleMeetingScreen extends StatefulWidget {
  const ScheduleMeetingScreen({super.key});

  @override
  _ScheduleMeetingScreenState createState() => _ScheduleMeetingScreenState();
}

class _ScheduleMeetingScreenState extends State<ScheduleMeetingScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedProfessor;
  int? facultyId;

  final TextEditingController reasonController = TextEditingController();
  List<Map<String, dynamic>> professors = [];
  bool _isLoading = true;
  late int studentId;

  @override
  void initState() {
    super.initState();
    studentId = AuthProvider.currentUserId ?? 0;
    fetchProfessors();
  }

  Future<void> fetchProfessors() async {
    final url = Uri.parse('http://10.0.2.2:5000/meeting/faculty/list');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          professors =
              data
                  .map<Map<String, dynamic>>(
                    (item) => {"name": item['name'], "id": item['id']},
                  )
                  .toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load professors');
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  void _pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  Future<void> _scheduleMeeting() async {
    if (selectedDate == null ||
        selectedTime == null ||
        facultyId == null ||
        reasonController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❗ Please fill all fields.")));
      return;
    }

    final url = Uri.parse('http://10.0.2.2:5000/meeting/schedule');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'student_id': studentId,
        'faculty_id': facultyId,
        'date': selectedDate!.toIso8601String().split('T')[0],
        'time': selectedTime!.format(context),
        'time_format': '24hr',
        'description': reasonController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("✅ Meeting Scheduled!")));
      reasonController.clear();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Failed to schedule meeting.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Meeting', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1F3A93),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          tileColor: Colors.white,
                          leading: Icon(
                            Icons.history,
                            color: Color(0xFF1F3A93),
                          ),
                          title: Text(
                            'My Meetings',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F3A93),
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black54,
                            size: 18,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StudentMeetingsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        'Select Professor',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        value: selectedProfessor,
                        items:
                            professors.map((prof) {
                              return DropdownMenuItem<String>(
                                value: prof['name'],
                                child: Text(prof['name']),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedProfessor = value;
                            facultyId =
                                professors.firstWhere(
                                  (prof) => prof['name'] == value,
                                )['id'];
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _pickDate,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: Color(0xFF1F3A93),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Pick Date',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      if (selectedDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Selected: ${selectedDate!.toLocal()}'.split(
                              ' ',
                            )[0],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _pickTime,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: Color(0xFF1F3A93),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Pick Time',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      if (selectedTime != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Selected: ${selectedTime!.format(context)}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      SizedBox(height: 20),
                      TextField(
                        controller: reasonController,
                        decoration: InputDecoration(
                          labelText: 'Reason for Meeting',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: _scheduleMeeting,
                        icon: Icon(Icons.check_circle_outline),
                        label: Text('Confirm Meeting'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: Color(0xFF1F3A93),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
