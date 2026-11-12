import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chip_to_crop/main.dart';
import 'package:chip_to_crop/core/constants/app_strings.dart';
import 'package:chip_to_crop/features/language/screens/language_selection_screen.dart';
import 'package:chip_to_crop/screens/splash/splash_screen.dart';
import 'package:chip_to_crop/screens/onboarding/onboarding_screen.dart';
import 'package:chip_to_crop/features/auth/screens/auth_choice_screen.dart';
import 'package:chip_to_crop/features/auth/screens/register_phone_screen.dart';
import 'package:chip_to_crop/features/auth/screens/login_phone_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Splash screen navigates to LanguageSelectionScreen on first launch',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({}); // First launch: no language selected

    await tester.pumpWidget(const ChipToCropApp());

    // Verify Splash Screen is initially displayed
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    // Verify NO text, tags, buttons or loading indicators on splash
    expect(find.byType(Text), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(ElevatedButton), findsNothing);

    // Advance animation past 2200ms duration + 600ms transition
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();

    // Verify LanguageSelectionScreen is shown on first launch
    expect(find.byType(LanguageSelectionScreen), findsOneWidget);
    expect(find.text('Choose Your Language'), findsOneWidget);
    expect(find.text('Select your preferred language'), findsOneWidget);
  });

  testWidgets('Splash screen navigates directly to Onboarding when language was already selected',
      (WidgetTester tester) async {
    // Set preference so user has already selected a language
    SharedPreferences.setMockInitialValues({
      'chip_to_crop_has_selected_language': true,
      'chip_to_crop_selected_language_code': 'en-IN',
    });

    await tester.pumpWidget(const ChipToCropApp());

    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();

    // Verify Onboarding Screen is shown directly
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text(AppStrings.onboarding1Title), findsOneWidget);
  });

  testWidgets(
      'Onboarding flow: Next, Skip, and Get Started navigation to AuthChoiceScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingScreen(),
      ),
    );

    // Verify screen 1 content
    expect(find.text(AppStrings.onboarding1Title), findsOneWidget);
    expect(find.text(AppStrings.onboarding1Description), findsOneWidget);
    expect(find.text(AppStrings.next), findsOneWidget);
    expect(find.text(AppStrings.skip), findsOneWidget);

    // Tap Next -> moves to screen 2
    await tester.tap(find.text(AppStrings.next));
    await tester.pumpAndSettle();

    // Verify screen 2 content
    expect(find.text(AppStrings.onboarding2Title), findsOneWidget);
    expect(find.text(AppStrings.onboarding2Description), findsOneWidget);
    expect(find.text(AppStrings.skip), findsOneWidget);

    // Tap Skip -> moves directly to final screen 3
    await tester.tap(find.text(AppStrings.skip));
    await tester.pumpAndSettle();

    // Verify screen 3 content
    expect(find.text(AppStrings.onboarding3Title), findsOneWidget);
    expect(find.text(AppStrings.onboarding3Description), findsOneWidget);
    expect(find.text(AppStrings.getStarted), findsOneWidget);

    // Tap Get Started -> navigates to AuthChoiceScreen
    await tester.tap(find.text(AppStrings.getStarted));
    await tester.pumpAndSettle();

    expect(find.byType(AuthChoiceScreen), findsOneWidget);
    expect(find.text('Welcome to Kisan Netra'), findsOneWidget);
    expect(find.text('Your farm. Your identity. Your digital companion.'),
        findsOneWidget);
    expect(find.text('REGISTER'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);

    // Tap REGISTER -> opens RegisterPhoneScreen
    await tester.tap(find.text('REGISTER'));
    await tester.pumpAndSettle();
    expect(find.byType(RegisterPhoneScreen), findsOneWidget);
    expect(find.text('Enter your mobile number'), findsOneWidget);

    // Go back
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    // Tap LOGIN -> opens LoginPhoneScreen
    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPhoneScreen), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
