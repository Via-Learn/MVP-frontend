// auth_repository.dart
abstract class AuthRepository {
  Future<Map<String, dynamic>> getUserData(String jwt);
  Future<void> createUser(String jwt, String username);
}
