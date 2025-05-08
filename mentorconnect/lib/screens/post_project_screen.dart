import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/auth_provider.dart';
import 'my_posted_projects_screen.dart';

class PostProjectScreen extends StatefulWidget {
  const PostProjectScreen({super.key});

  @override
  _PostProjectScreenState createState() => _PostProjectScreenState();
}

class _PostProjectScreenState extends State<PostProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _slots = 1;

  Future<void> _postProject() async {
    final int facultyId = AuthProvider.currentUserId ?? 0;

    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('http://10.0.2.2:5000/project/post');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "faculty_id": facultyId,
          "faculty_name": "Faculty", // Replace if you store name dynamically
          "title": _titleController.text,
          "description": _descriptionController.text,
          "slots": _slots,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Project posted successfully')),
        );
        _formKey.currentState!.reset();
        setState(() => _slots = 1);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Failed to post project')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post a Project', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1F3A93),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.folder_open),
                label: Text("View Posted Projects"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MyPostedProjectsScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 30),
              Text(
                "Create a New Project",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F3A93),
                ),
              ),
              SizedBox(height: 20),
              _buildInputField("Project Title", _titleController),
              SizedBox(height: 16),
              _buildDescriptionField(
                "Project Description",
                _descriptionController,
              ),
              SizedBox(height: 16),
              Text("Available Slots", style: TextStyle(fontSize: 16)),
              SizedBox(height: 6),
              DropdownButtonFormField<int>(
                value: _slots,
                onChanged: (val) => setState(() => _slots = val!),
                items:
                    List.generate(10, (index) => index + 1)
                        .map(
                          (val) => DropdownMenuItem(
                            value: val,
                            child: Text(val.toString()),
                          ),
                        )
                        .toList(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _postProject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1F3A93),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Post Project',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      validator: (val) => val!.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildDescriptionField(
    String label,
    TextEditingController controller,
  ) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      validator: (val) => val!.isEmpty ? 'Please enter $label' : null,
    );
  }
}
