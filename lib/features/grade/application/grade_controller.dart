import 'dart:io';
import '../data/grade_remote_datasource.dart';
import '../domain/grade_feedback.dart';

class GradeController {
  final GradeRemoteDataSource _dataSource = GradeRemoteDataSource();

  Future<AutogradeFeedback> gradeSubmission(File questionPaper, File writeup) {
    return _dataSource.submitForAutograde(questionPaper, writeup);
  }
}
