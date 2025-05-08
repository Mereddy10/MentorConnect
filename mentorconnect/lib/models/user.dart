class User {
  final String id;
  final String name;
  final String contactNumber;
  final String email;
  final String dob;
  final String branch;
  final double cgpa;
  final List<String> projectsDone;
  final String role; // 'student' or 'faculty'

  User({
    required this.id,
    required this.name,
    required this.contactNumber,
    required this.email,
    required this.dob,
    required this.branch,
    required this.cgpa,
    required this.projectsDone,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      contactNumber: json['contactNumber'],
      email: json['email'],
      dob: json['dob'],
      branch: json['branch'],
      cgpa: json['cgpa'].toDouble(),
      projectsDone: List<String>.from(json['projectsDone']),
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "contactNumber": contactNumber,
      "email": email,
      "dob": dob,
      "branch": branch,
      "cgpa": cgpa,
      "projectsDone": projectsDone,
      "role": role,
    };
  }
}
