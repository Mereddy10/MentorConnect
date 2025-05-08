import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/auth_provider.dart';

class FacultyProfile extends StatefulWidget {
  const FacultyProfile({super.key});

  @override
  _FacultyProfileState createState() => _FacultyProfileState();
}

class _FacultyProfileState extends State<FacultyProfile> {
  final themeColor = const Color(0xFF1F3A93);

  final _nameController = TextEditingController();
  final _facultyIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _designationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _officeController = TextEditingController();
  final _project1Controller = TextEditingController();
  final _project2Controller = TextEditingController();
  final _project3Controller = TextEditingController();
  final _aboutController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchFacultyProfile();
  }

  Future<void> fetchFacultyProfile() async {
    final int facultyId = AuthProvider.currentUserId ?? 0;
    final url = Uri.parse('http://10.0.2.2:5000/auth/profile/$facultyId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _nameController.text = data['name'] ?? '';
          _facultyIdController.text = data['faculty_id']?.toString() ?? '';
          _departmentController.text = data['branch'] ?? '';
          _designationController.text = data['designation'] ?? '';
          _experienceController.text = data['experience'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _officeController.text = data['address'] ?? '';
          _aboutController.text = data['description'] ?? '';
          if (data['project_titles'] != null) {
            List<String> projects = data['project_titles'].split(';');
            _project1Controller.text = projects.isNotEmpty ? projects[0] : '';
            _project2Controller.text = projects.length > 1 ? projects[1] : '';
            _project3Controller.text = projects.length > 2 ? projects[2] : '';
          }
        });
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  Future<void> saveFacultyProfile() async {
    final int facultyId = AuthProvider.currentUserId ?? 0;
    final url = Uri.parse('http://10.0.2.2:5000/auth/profile');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "user_id": facultyId,
        "name": _nameController.text,
        "faculty_id": _facultyIdController.text,
        "branch": _departmentController.text,
        "designation": _designationController.text,
        "experience": _experienceController.text,
        "email": _emailController.text,
        "phone": _phoneController.text,
        "address": _officeController.text,
        "description": _aboutController.text,
        "project_titles": [
          _project1Controller.text,
          _project2Controller.text,
          _project3Controller.text,
        ].join(';'),
      }),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("✅ Profile updated!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Faculty Profile'),
          leading: BackButton(color: Colors.white),
          backgroundColor: themeColor,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'Profile'),
              Tab(text: 'Contact'),
              Tab(text: 'Projects'),
              Tab(text: 'About'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _buildProfileTab(),
                  _buildContactTab(),
                  _buildProjectsDoneTab(),
                  _buildAboutMeTab(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: saveFacultyProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
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

  Widget _buildInputForm(List<Widget> fields) => Padding(
    padding: const EdgeInsets.all(16),
    child: ListView(children: fields),
  );

  Widget _inputField(String label, TextEditingController controller) => Padding(
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

  Widget _buildProfileTab() => _buildInputForm([
    _inputField('Name', _nameController),
    _inputField('Faculty ID', _facultyIdController),
    _inputField('Department', _departmentController),
    _inputField('Designation', _designationController),
    _inputField('Experience', _experienceController),
  ]);

  Widget _buildContactTab() => _buildInputForm([
    _inputField('Email', _emailController),
    _inputField('Phone', _phoneController),
    _inputField('Office', _officeController),
  ]);

  Widget _buildProjectsDoneTab() => _buildInputForm([
    _inputField('Project 1 Title', _project1Controller),
    _inputField('Project 2 Title', _project2Controller),
    _inputField('Project 3 Title', _project3Controller),
  ]);

  Widget _buildAboutMeTab() => Padding(
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
