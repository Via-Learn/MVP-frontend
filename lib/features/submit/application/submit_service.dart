// submit_service.dart
import 'package:flutter/material.dart';
import '../domain/assignment_model.dart';
import '../data/submit_remote_datasource.dart';

class SubmitController with ChangeNotifier {
  final SubmitRemoteDataSource _dataSource = SubmitRemoteDataSource();

  Map<int, List<Assignment>> assignmentsByCourse = {};
  List<dynamic> courses = [];
  bool isLoading = false;
  bool isCanvasLinked = false;

  Future<void> checkLinkStatus() async {
    isLoading = true;
    notifyListeners();

    try {
      isCanvasLinked = await _dataSource.isCanvasLinked();
    } catch (e) {
      debugPrint("❌ Link check error: $e");
      isCanvasLinked = false;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadCourses() async {
    isLoading = true;
    notifyListeners();

    try {
      courses = await _dataSource.fetchCourses();
      for (var course in courses) {
        final id = course['id'];
        assignmentsByCourse[id] = await _dataSource.fetchAssignments(id);
      }
    } catch (e) {
      debugPrint("❌ Course load error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> handleSubmit(int courseId, int assignmentIndex) async {
    try {
      final assignment = assignmentsByCourse[courseId]![assignmentIndex];
      final file = await _dataSource.pickFile();
      if (file == null) return;
      await _dataSource.submitAssignment(courseId, assignment.id, file);
      assignment.status = 'Submitted';
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Submission error: $e");
    }
  }

  Future<void> loadCanvasCoursesIfLinked() async {
    isLoading = true;
    notifyListeners();

    try {
      // Just attempt to load, and catch failure if not linked or no courses
      courses = await _dataSource.fetchCourses();
      for (var course in courses) {
        final id = course['id'];
        assignmentsByCourse[id] = await _dataSource.fetchAssignments(id);
      }
    } catch (e) {
      debugPrint("❌ Canvas course load error: $e");
      courses = [];
      assignmentsByCourse.clear();
    }

    isLoading = false;
    notifyListeners();
  }
}
