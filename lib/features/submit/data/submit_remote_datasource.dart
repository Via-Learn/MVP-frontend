// features/submit/data/submit_remote_datasource.dart
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/config.dart';
import '../../../core/constants/routes.dart';
import '../../../core/network/backend_client.dart'; // <-- backend wrapper
import '../domain/assignment_model.dart';

class SubmitRemoteDataSource {
  final BackendClient _client;

  SubmitRemoteDataSource({BackendClient? client})
      : _client = client ?? BackendClient();

  Future<List<dynamic>> fetchCourses() async {
    final response = await _client.get(ApiRoutes.LMS_GET_COURSES);

    if (response.statusCode != 200) throw Exception(response.body);
    return jsonDecode(response.body)['courses'];
  }

  Future<List<Assignment>> fetchAssignments(int courseId) async {
    final response = await _client.get('/lms/assignments/$courseId');

    if (response.statusCode != 200) throw Exception(response.body);

    final jsonList = jsonDecode(response.body)['assignments'];
    return List<Assignment>.from(jsonList.map((e) => Assignment.fromJson(e)));
  }

  Future<void> submitAssignment(int courseId, int assignmentId, File file) async {
    var multipartResponse = await _client.multipart(
      ApiRoutes.LMS_POST_SUBMIT,
      {
        'course_id': courseId.toString(),
        'assignment_id': assignmentId.toString(),
      },
      [await http.MultipartFile.fromPath('file', file.path)],
    );

    final response = await http.Response.fromStream(multipartResponse);

    if (response.statusCode != 200) {
      throw Exception("Submission failed: ${response.statusCode}: ${response.body}");
    }
  }

  Future<File?> pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    return result != null ? File(result.files.single.path!) : null;
  }
}
