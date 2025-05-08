import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/auth_provider.dart';
import 'dart:io';
import 'package:file_selector/file_selector.dart';
import '../models/project.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  _ProjectDetailsScreenState createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  File? selectedPDF;
  String? selectedPDFName;
  bool alreadyApplied = false;

  @override
  void initState() {
    super.initState();
    checkAlreadyApplied();
  }

  Future<void> checkAlreadyApplied() async {
    final studentId = AuthProvider.currentUserId ?? 0;
    final url = Uri.parse(
      'http://10.0.2.2:5000/application/student/$studentId',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final appliedProjectIds = data.map((e) => e['project_id']).toList();
      setState(() {
        alreadyApplied = appliedProjectIds.contains(widget.project.id);
      });
    }
  }

  Future<void> pickPDF() async {
    final XTypeGroup typeGroup = XTypeGroup(label: 'pdf', extensions: ['pdf']);
    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);

    if (file != null) {
      setState(() {
        selectedPDF = File(file.path);
        selectedPDFName = file.name;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("✅ Selected: ${file.name}")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ No file selected")));
    }
  }

  Future<void> applyForProject(BuildContext context, int projectId) async {
    final studentId = AuthProvider.currentUserId ?? 0;
    final uri = Uri.parse('http://10.0.2.2:5000/application/submit');
    var request = http.MultipartRequest('POST', uri);
    request.fields['student_id'] = studentId.toString();
    request.fields['project_id'] = projectId.toString();
    request.files.add(
      await http.MultipartFile.fromPath('statement_file', selectedPDF!.path),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      setState(() => alreadyApplied = true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("✅ Application submitted!")));
    } else {
      final responseBody = await response.stream.bytesToString();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Failed: $responseBody")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;

    return Scaffold(
      appBar: AppBar(
        title: Text('Project Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1F3A93),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3A93),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  project.description,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                Divider(height: 30),
                _infoRow("Professor", project.professor),
                _infoRow(
                  "Available Slots",
                  project.availableSlots > 0
                      ? '${project.availableSlots} Available'
                      : 'Already Allocated',
                  valueColor:
                      project.availableSlots > 0 ? Colors.green : Colors.red,
                ),
                SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: pickPDF,
                  icon: Icon(Icons.upload_file),
                  label: Text('Upload Statement of Interest (PDF)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  selectedPDFName != null
                      ? "📄 Selected: $selectedPDFName"
                      : "No file selected",
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 25),
                Center(
                  child:
                      alreadyApplied
                          ? Text(
                            "📌 You have already applied for this project.",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          : project.availableSlots == 0
                          ? Text(
                            "⚠️ This project is full.",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          : ElevatedButton(
                            onPressed: () {
                              if (selectedPDF == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "📎 Please upload a PDF first",
                                    ),
                                  ),
                                );
                              } else {
                                applyForProject(context, project.id);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1F3A93),
                              padding: EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Apply for Project',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
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

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: valueColor ?? Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
