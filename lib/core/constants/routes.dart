// routes.dart
// GENERATED FILE — DO NOT EDIT MANUALLY
// Run `python generate_routes_dart.py` to regenerate.

class ApiRoutes {
  static const String LLM_POST_CHAT = "/llm/chat";
  static const String LLM_POST_RAG = "/llm/rag";
  static const String LLM_POST_EMBED = "/llm/embed";

  static const String RAG_GET_FILES = "/rag/files";
  static const String RAG_GET_FILE_STATS = "/rag/files/stats";
  static const String RAG_DELETE_DELETE_FILE = "/rag/files/delete";

  static const String USERDB_GET_ME = "/userdb/me";
  static const String USERDB_GET_BY_EMAIL = "/userdb/by-email";
  static const String USERDB_GET_BY_USERNAME = "/userdb/by-username";
  static const String USERDB_POST_CREATE = "/userdb/create";
  static const String USERDB_POST_SIGN_TOKEN = "/userdb/sign-token"; // ✅ Added
  static const String USERDB_PUT_UPDATE = "/userdb/update";
  static const String USERDB_DELETE_DELETE = "/userdb/delete";

  static const String TOKENDB_GET_TOKENS = "/tokendb/tokens";
  static const String TOKENDB_POST_STORE = "/tokendb/store";
  static const String TOKENDB_PUT_UPDATE = "/tokendb/update";
  static const String TOKENDB_DELETE_DELETE = "/tokendb/delete";

  static const String EVENTS_POST_EXTRACT = "/events/extract";
  static const String EVENTS_POST_CREATE = "/events/create";
  static const String EVENTS_POST_READ = "/events/day";

  static const String LMS_GET_COURSES = "/lms/courses";
  static const String LMS_GET_ASSIGNMENTS = "/lms/assignments/course_id";
  static const String LMS_POST_SUBMIT = "/lms/submit";

  static const String CANVAS_POST_REAUTH = "/canvas/reauth-url";
  static const String CANVAS_GET_AUTH = "/oauth2/callback";

  static const String GOOGLE_GET_REAUTH_URL = "/google/reauth-url";
  static const String GOOGLE_GET_OAUTH_CALLBACK = "/google/oauth2/callback";

  static const String AUTOGRADE = "/autograde";
}
