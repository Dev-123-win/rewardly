class AuthResult {
  final bool success;
  final String? message;
  final String? uid; // User ID on success

  AuthResult({required this.success, this.message, this.uid});

  // Factory constructor for success
  factory AuthResult.success({required String uid}) {
    return AuthResult(success: true, uid: uid);
  }

  // Factory constructor for failure
  factory AuthResult.failure({required String message}) {
    return AuthResult(success: false, message: message);
  }
}
