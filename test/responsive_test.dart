import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chip_to_crop/screens/splash/splash_screen.dart';
import 'package:chip_to_crop/screens/onboarding/onboarding_screen.dart';

void main() {
  const testSizes = [
    Size(320, 568), // Small phone (iPhone SE 1st gen / small Android)
    Size(360, 640), // Classic Android 16:9
    Size(393, 852), // Modern standard phone (e.g. Pixel / iPhone)
    Size(412, 915), // Tall modern Android (e.g. Galaxy S21 / Pixel 7)
    Size(600, 960), // Small tablet
  ];

  for (final size in testSizes) {
    testWidgets('Responsiveness test for screen size ${size.width}x${size.height}',
        (WidgetTester tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Verify Splash Screen renders without overflow
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );
      expect(tester.takeException(), isNull);

      // Verify Onboarding Screen renders across all 3 pages without overflow
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );
      expect(tester.takeException(), isNull);

      // Navigate to page 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Navigate to page 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}

