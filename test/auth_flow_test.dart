import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chip_to_crop/features/auth/screens/auth_choice_screen.dart';
import 'package:chip_to_crop/features/auth/screens/register_phone_screen.dart';
import 'package:chip_to_crop/features/auth/screens/login_phone_screen.dart';
import 'package:chip_to_crop/features/auth/screens/face_capture_screen.dart';
import 'package:chip_to_crop/features/auth/models/auth_models.dart';
import 'package:chip_to_crop/features/auth/services/auth_service.dart';

// Mock AuthService for deterministic widget testing
class MockAuthService extends AuthService {
  final bool shouldSucceed;
  final String? errorMessage;

  MockAuthService({this.shouldSucceed = true, this.errorMessage});

  @override
  Future<bool> checkPhoneExists(String phoneNumber) async {
    return shouldSucceed;
  }

  @override
  Future<AuthResult> register({
    required String phoneNumber,
    required List<int> imageBytes,
    required String filename,
    required bool consent,
  }) async {
    if (shouldSucceed) {
      return AuthResult.success(
        message: 'Registration successful!',
        token: 'mock_jwt_token',
        farmerId: 'farmer_9876543210',
        isDemo: true,
      );
    } else {
      return AuthResult.failure(
        message: errorMessage ?? 'Registration failed',
        errorCode: 'REGISTRATION_ERROR',
      );
    }
  }

  @override
  Future<AuthResult> login({
    required String phoneNumber,
    required List<int> imageBytes,
    required String filename,
  }) async {
    if (shouldSucceed) {
      return AuthResult.success(
        message: 'Face verified successfully.',
        token: 'mock_jwt_token',
        farmerId: 'farmer_9876543210',
        confidence: 94.5,
        isDemo: true,
      );
    } else {
      return AuthResult.failure(
        message: errorMessage ?? 'Face verification failed',
        errorCode: 'VERIFICATION_FAILED',
        remainingAttempts: 2,
      );
    }
  }
}

void main() {
  group('AuthChoiceScreen Tests', () {
    testWidgets('Renders logo, title, and both action buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AuthChoiceScreen()),
      );

      expect(find.text('Welcome to Kisan Netra'), findsOneWidget);
      expect(find.text('Your farm. Your identity. Your digital companion.'),
          findsOneWidget);
      expect(find.text('REGISTER'), findsOneWidget);
      expect(find.text('LOGIN'), findsOneWidget);
      expect(find.text('Bank-grade biometric encryption & privacy'),
          findsOneWidget);
    });
  });

  group('RegisterPhoneScreen Validation Tests', () {
    testWidgets('Validates empty, short, and invalid mobile numbers',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RegisterPhoneScreen()),
      );

      // 1. Empty tap
      await tester.tap(find.text('CONTINUE WITH FACE REGISTRATION'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter your 10-digit mobile number'), findsOneWidget);

      // 2. Short number
      await tester.enterText(find.byType(TextField), '98765');
      await tester.tap(find.text('CONTINUE WITH FACE REGISTRATION'));
      await tester.pumpAndSettle();
      expect(find.text('Mobile number must be exactly 10 digits'), findsOneWidget);

      // 3. Invalid starting digit
      await tester.enterText(find.byType(TextField), '1234567890');
      await tester.tap(find.text('CONTINUE WITH FACE REGISTRATION'));
      await tester.pumpAndSettle();
      expect(
          find.text('Please enter a valid Indian mobile number starting with 6-9'),
          findsOneWidget);

      // 4. Valid Indian mobile number
      await tester.enterText(find.byType(TextField), '9876543210');
      await tester.tap(find.text('CONTINUE WITH FACE REGISTRATION'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(FaceCaptureScreen), findsOneWidget);
      expect(find.text('Face Registration'), findsOneWidget);
    });
  });

  group('LoginPhoneScreen Validation Tests', () {
    testWidgets('Validates mobile number and proceeds to Face Login',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginPhoneScreen()),
      );

      // 1. Empty tap
      await tester.tap(find.text('VERIFY WITH FACE'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter your registered mobile number'), findsOneWidget);

      // 2. Valid number proceeds
      await tester.enterText(find.byType(TextField), '9876543210');
      await tester.tap(find.text('VERIFY WITH FACE'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(FaceCaptureScreen), findsOneWidget);
      expect(find.text('Face Verification'), findsOneWidget);
    });
  });

  group('FaceCaptureScreen Simulation & Review Tests', () {
    testWidgets('Registration mode captures, requires consent, and confirms',
        (WidgetTester tester) async {
      final mockAuth = MockAuthService(shouldSucceed: true);

      await tester.pumpWidget(
        MaterialApp(
          home: FaceCaptureScreen(
            mode: FaceCaptureMode.register,
            phoneNumber: '+919876543210',
            authService: mockAuth,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Face Registration'), findsOneWidget);
      expect(find.text('Position your face inside the green frame'), findsOneWidget);

      // Tap capture button
      await tester.tap(find.byIcon(Icons.camera_alt_rounded));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Review view is shown with consent checkbox
      expect(find.text('Review Face Photograph'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.text('CONFIRM & REGISTER'), findsOneWidget);
      expect(find.text('Retake'), findsOneWidget);

      // Tap Confirm & Register
      await tester.tap(find.text('CONFIRM & REGISTER'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Preparing Verification'), findsOneWidget);

      // Allow 700ms preparing delay + mock API call to complete
      await tester.pump(const Duration(milliseconds: 800));

      // Success reached
      expect(find.text('Registration Complete!'), findsOneWidget);

      // Wait out the 1400ms success presentation timer and navigation transition
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('Login mode captures and verifies face',
        (WidgetTester tester) async {
      final mockAuth = MockAuthService(shouldSucceed: true);

      await tester.pumpWidget(
        MaterialApp(
          home: FaceCaptureScreen(
            mode: FaceCaptureMode.login,
            phoneNumber: '+919876543210',
            authService: mockAuth,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Face Verification'), findsOneWidget);

      // Tap capture button
      await tester.tap(find.byIcon(Icons.camera_alt_rounded));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Review view
      expect(find.text('Confirm Face for Login'), findsOneWidget);
      expect(find.text('VERIFY FACE'), findsOneWidget);

      // Tap Verify Face
      await tester.tap(find.text('VERIFY FACE'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Preparing Verification'), findsOneWidget);

      // Allow 700ms preparing delay + mock API call to complete
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.text('Identity Verified!'), findsOneWidget);

      // Wait out the 1400ms success presentation timer and navigation transition
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump(const Duration(milliseconds: 500));
    });
  });
}
