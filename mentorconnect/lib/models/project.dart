class Project {
  final int id;
  final String title;
  final String description;
  final String professor;
  int availableSlots;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.professor,
    required this.availableSlots,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      professor: json['faculty_name'], // <- use this field
      availableSlots: json['slots'],
    );
  }
}
