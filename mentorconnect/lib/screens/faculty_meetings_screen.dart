import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/auth_provider.dart';

class FacultyMeetingsScreen extends StatefulWidget {
  const FacultyMeetingsScreen({super.key});

  @override
  _FacultyMeetingsScreenState createState() => _FacultyMeetingsScreenState();
}

class _FacultyMeetingsScreenState extends State<FacultyMeetingsScreen> {
  List<dynamic> meetings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMeetings();
  }

  Future<void> fetchMeetings() async {
    final int facultyId = AuthProvider.currentUserId ?? 0;
    final url = Uri.parse('http://10.0.2.2:5000/meeting/faculty/$facultyId');
    try {
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          meetings = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        print('Failed to load meetings');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error: $e');
    }
  }

  void respondToMeeting(Map<String, dynamic> data) async {
    final int facultyId = AuthProvider.currentUserId ?? 0;
    final url = Uri.parse('http://10.0.2.2:5000/meeting/faculty/$facultyId');
    try {
      final response = await http.post(url, body: data);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('✅ Response submitted!')));
        fetchMeetings();
      } else {
        print('❌ Server error: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception: $e');
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingCard(dynamic meeting) {
    final TextEditingController messageController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    final TextEditingController timeController = TextEditingController();

    bool isFinalized = meeting['status'] != 'Pending';

    String action = 'Accept';
    String mode = 'Online';
    String timeFormat = 'AM';

    return StatefulBuilder(
      builder: (context, setInnerState) {
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow('Student Name', meeting['student_name'] ?? 'N/A'),
                _infoRow(
                  'Meeting Reason',
                  meeting['description'] ?? 'No reason provided',
                ),
                _infoRow('Date', meeting['date']),
                _infoRow(
                  'Time',
                  '${meeting['time']} ${meeting['time_format']}',
                ),
                SizedBox(height: 6),
                Text(
                  'Status: ${meeting['status']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        meeting['status'] == 'Accepted'
                            ? Colors.green
                            : meeting['status'] == 'Rejected'
                            ? Colors.red
                            : Colors.orange,
                  ),
                ),
                if (!isFinalized) ...[
                  SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: action,
                    onChanged: (val) {
                      setInnerState(() {
                        action = val!;
                        if (action != 'Reschedule') {
                          dateController.clear();
                          timeController.clear();
                        }
                      });
                    },
                    decoration: InputDecoration(labelText: 'Action'),
                    items:
                        ['Accept', 'Reschedule', 'Rejected']
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                  ),
                  if (action == 'Accept')
                    DropdownButtonFormField<String>(
                      value: mode,
                      onChanged: (val) {
                        setInnerState(() => mode = val!);
                      },
                      decoration: InputDecoration(
                        labelText: 'Mode (if Accepted)',
                      ),
                      items:
                          ['Online', 'Offline']
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                    ),
                  if (action == 'Reschedule') ...[
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(Duration(days: 1)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2026),
                        );
                        if (pickedDate != null) {
                          setInnerState(() {
                            dateController.text =
                                pickedDate.toString().split(' ')[0];
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: dateController,
                          decoration: InputDecoration(
                            labelText: 'Pick New Date',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (pickedTime != null) {
                                setInnerState(() {
                                  timeController.text = pickedTime.format(
                                    context,
                                  );
                                });
                              }
                            },
                            child: AbsorbPointer(
                              child: TextFormField(
                                controller: timeController,
                                decoration: InputDecoration(
                                  labelText: 'Pick New Time',
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: timeFormat,
                            onChanged: (val) {
                              setInnerState(() => timeFormat = val!);
                            },
                            decoration: InputDecoration(labelText: 'AM/PM'),
                            items:
                                ['AM', 'PM']
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 12),
                  TextFormField(
                    controller: messageController,
                    decoration: InputDecoration(
                      labelText: 'Message (optional)',
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final formData = {
                          'meeting_id': meeting['id'].toString(),
                          'status': action,
                          'mode': action == 'Accept' ? mode : '',
                          'new_date':
                              action == 'Reschedule' ? dateController.text : '',
                          'new_time':
                              action == 'Reschedule' ? timeController.text : '',
                          'time_format':
                              action == 'Reschedule' ? timeFormat : '',
                          'message': messageController.text,
                        };
                        respondToMeeting(formData);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1F3A93),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Submit Response',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      '✅ This meeting is finalized.',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Meeting Requests', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1F3A93),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : meetings.isEmpty
              ? Center(child: Text('No meeting requests found.'))
              : ListView.builder(
                itemCount: meetings.length,
                itemBuilder:
                    (context, index) => _buildMeetingCard(meetings[index]),
              ),
    );
  }
}
