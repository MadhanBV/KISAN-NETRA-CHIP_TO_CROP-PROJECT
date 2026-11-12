/// Mode for the face capture camera interface.
enum FaceCaptureMode {
  register,
  login,
}

/// Authentication state results.
class AuthResult {
  final bool success;
  final String message;
  final String? token;
  final String? farmerId;
  final double? confidence;
  final int? remainingAttempts;
  final String? errorCode;
  final bool isDemo;

  const AuthResult({
    required this.success,
    required this.message,
    this.token,
    this.farmerId,
    this.confidence,
    this.remainingAttempts,
    this.errorCode,
    this.isDemo = false,
  });

  factory AuthResult.success({
    required String message,
    String? token,
    String? farmerId,
    double? confidence,
    bool isDemo = false,
  }) {
    return AuthResult(
      success: true,
      message: message,
      token: token,
      farmerId: farmerId,
      confidence: confidence,
      isDemo: isDemo,
    );
  }

  factory AuthResult.failure({
    required String message,
    String? errorCode,
    int? remainingAttempts,
  }) {
    return AuthResult(
      success: false,
      message: message,
      errorCode: errorCode,
      remainingAttempts: remainingAttempts,
    );
  }
}

