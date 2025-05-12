import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../../../core/constants/config.dart';
import '../domain/grade_feedback.dart';
import '../../../core/constants/routes.dart';

class GradeRemoteDataSource {
  Future<AutogradeFeedback> submitForAutograde(File questionPaper, File studentWriteup) async {
    final uri = Uri.parse('$baseUrl${ApiRoutes.AUTOGRADE}');
    var request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath(
      'question_paper',
      questionPaper.path,
      contentType: MediaType('application', 'pdf'),
    ));

    request.files.add(await http.MultipartFile.fromPath(
      'student_writeup',
      studentWriteup.path,
      contentType: MediaType('application', 'pdf'),
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Grading failed: ${response.body}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return AutogradeFeedback.fromJson(data);
  }
}
