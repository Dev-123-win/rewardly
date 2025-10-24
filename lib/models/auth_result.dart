class AuthResult {
  final bool success;
  final String? message;
  final String? uid; // User ID on success
  final String? email; // User email on success
  final String? projectId; // Project ID on success

  AuthResult({required this.success, this.message, this.uid, this.email, this.projectId});

  // Factory constructor for success
  factory AuthResult.success({required String uid, String? email, String? projectId}) {
    return AuthResult(success: true, uid: uid, email: email, projectId: projectId);
  }

  // Factory constructor for failure
  factory AuthResult.failure({required String message}) {
    return AuthResult(success: false, message: message);
  }
}
