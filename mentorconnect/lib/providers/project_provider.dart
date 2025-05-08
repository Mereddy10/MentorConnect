import 'package:flutter/material.dart';
import '../models/project.dart';

class ProjectProvider with ChangeNotifier {
  final List<Project> _projects = [];

  List<Project> get projects => _projects;

  void addProject(Project project) {
    _projects.add(project);
    notifyListeners();
  }

  void removeProject(String id) {
    _projects.removeWhere((proj) => proj.id == id);
    notifyListeners();
  }
}
