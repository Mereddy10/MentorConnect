import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/auth_provider.dart'; // ✅ Authenticated student ID

class StudentProfile extends StatefulWidget {
  const StudentProfile({super.key});

  @override
  _StudentProfileState createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  final _nameController = TextEditingController();
  final _enrollController = TextEditingController();
  final _dobController = TextEditingController();
  final _branchController = TextEditingController();
  final _yearController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _project1Controller = TextEditingController();
  final _project2Controller = TextEditingController();
  final _project3Controller = TextEditingController();
  final _aboutController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final int userId = AuthProvider.currentUserId ?? 0;
    final url = Uri.parse('http://10.0.2.2:5000/auth/profile/$userId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _nameController.text = data['name'] ?? '';
          _enrollController.text = data['enrollment_no'] ?? '';
          _dobController.text = data['dob'] ?? '';
          _branchController.text = data['branch'] ?? '';
          _yearController.text = data['year']?.toString() ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _addressController.text = data['address'] ?? '';
          _aboutController.text = data['description'] ?? '';
          if (data['project_titles'] != null) {
            List<String> projects = data['project_titles'].split(';');
            _project1Controller.text = projects.isNotEmpty ? projects[0] : '';
            _project2Controller.text = projects.length > 1 ? projects[1] : '';
            _project3Controller.text = projects.length > 2 ? projects[2] : '';
          }
        });
      } else {
        print('Error fetching profile: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception fetching profile: $e');
    }
  }

  Future<void> saveProfile() async {
    final int userId = AuthProvider.currentUserId ?? 0;
    final url = Uri.parse('http://10.0.2.2:5000/auth/profile');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "user_id": userId,
        "name": _nameController.text,
        "enrollment_no": _enrollController.text,
        "dob": _dobController.text,
        "branch": _branchController.text,
        "year": _yearController.text,
        "email": _emailController.text,
        "phone": _phoneController.text,
        "address": _addressController.text,
        "description": _aboutController.text,
        "project_titles": [
          _project1Controller.text,
          _project2Controller.text,
          _project3Controller.text,
        ].join(';'),
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Profile updated successfully!")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Failed to update profile.")));
      print("Error: ${response.statusCode} ${response.body}");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _enrollController.dispose();
    _dobController.dispose();
    _branchController.dispose();
    _yearController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _project1Controller.dispose();
    _project2Controller.dispose();
    _project3Controller.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Student Profile'),
          leading: BackButton(color: Colors.white),
          backgroundColor: Color(0xFF1F3A93),
          elevation: 1,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Personal'),
              Tab(text: 'Contact'),
              Tab(text: 'Projects'),
              Tab(text: 'About Me'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _buildPersonalTab(),
                  _buildContactTab(),
                  _buildProjectsDoneTab(),
                  _buildAboutMeTab(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1F3A93),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Save Profile",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalTab() {
    return _buildInputForm([
      _inputField('Name', _nameController),
      _inputField('Enrollment No', _enrollController),
      _inputField('Date of Birth', _dobController),
      _inputField('Branch', _branchController),
      _inputField('Year', _yearController),
    ]);
  }

  Widget _buildContactTab() {
    return _buildInputForm([
      _inputField('Email', _emailController),
      _inputField('Phone', _phoneController),
      _inputField('Address', _addressController),
    ]);
  }

  Widget _buildProjectsDoneTab() {
    return _buildInputForm([
      _inputField('Project 1 Title', _project1Controller),
      _inputField('Project 2 Title', _project2Controller),
      _inputField('Project 3 Title', _project3Controller),
    ]);
  }

  Widget _buildAboutMeTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextFormField(
        controller: _aboutController,
        maxLines: 8,
        decoration: InputDecoration(
          labelText: 'Write about yourself...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade100,
          alignLabelWithHint: true,
        ),
      ),
    );
  }

  Widget _buildInputForm(List<Widget> fields) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(children: fields),
    );
  }

  Widget _inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }
}
