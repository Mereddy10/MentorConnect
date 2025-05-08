import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/project.dart';

import 'project_details_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  _ProjectListScreenState createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  List<Project> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/project/available'),
      );
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _projects = data.map((item) => Project.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        print('Failed to load projects: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching projects: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Available Projects',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF1F3A93),
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _projects.isEmpty
              ? Center(child: Text('No available projects.'))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    final project = _projects[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: Icon(
                          Icons.folder,
                          color: Color(0xFF1F3A93),
                          size: 36,
                        ),
                        title: Text(
                          project.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '${project.description}\nProfessor: ${project.professor}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        trailing: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                project.availableSlots > 0
                                    ? Colors.green
                                    : Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            project.availableSlots > 0
                                ? "Slots: ${project.availableSlots}"
                                : "Full",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ProjectDetailsScreen(project: project),
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
