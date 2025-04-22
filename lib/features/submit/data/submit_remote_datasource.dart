import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/config.dart';
import '../../../core/constants/routes.dart';
import '../domain/assignment_model.dart';

class SubmitRemoteDataSource {
  Future<String?> _getJwt() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.getIdToken(true);
  }

  Future<List<dynamic>> fetchCourses() async {
    final jwt = await _getJwt();
    final response = await http.get(
      Uri.parse('$baseUrl${ApiRoutes.LMS_GET_COURSES}'),
      headers: {'Authorization': 'Bearer $jwt'},
    );
    if (response.statusCode != 200) throw Exception(response.body);
    return jsonDecode(response.body)['courses'];
  }

  Future<List<Assignment>> fetchAssignments(int courseId) async {
    final jwt = await _getJwt();
    final response = await http.get(
      Uri.parse('$baseUrl/lms/assignments/$courseId'),
      headers: {'Authorization': 'Bearer $jwt'},
    );
    if (response.statusCode != 200) throw Exception(response.body);
    final jsonList = jsonDecode(response.body)['assignments'];
    return List<Assignment>.from(jsonList.map((e) => Assignment.fromJson(e)));
  }

  Future<void> submitAssignment(int courseId, int assignmentId, File file) async {
    final jwt = await _getJwt();
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl${ApiRoutes.LMS_POST_SUBMIT}'));
    request.headers['Authorization'] = 'Bearer $jwt';
    request.fields['course_id'] = courseId.toString();
    request.fields['assignment_id'] = assignmentId.toString();
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception(await http.Response.fromStream(response).then((res) => res.body));
    }
  }

  Future<File?> pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    return result != null ? File(result.files.single.path!) : null;
  }
}
