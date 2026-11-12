import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chip_to_crop/core/localization/app_language.dart';
import 'package:chip_to_crop/core/localization/language_service.dart';
import 'package:chip_to_crop/core/localization/locale_controller.dart';
import 'package:chip_to_crop/features/language/screens/language_selection_screen.dart';
import 'package:chip_to_crop/features/language/widgets/language_card.dart';
import 'package:chip_to_crop/l10n/app_localizations.dart';
import 'package:chip_to_crop/screens/onboarding/onboarding_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppLanguage Model Tests', () {
    test('Supports all 23 official languages for Sarvam-Translate v1', () {
      expect(AppLanguage.supportedLanguages.length, 23);

      final codes = AppLanguage.supportedLanguages.map((l) => l.code).toList();
      expect(codes, contains('en-IN'));
      expect(codes, contains('hi-IN'));
      expect(codes, contains('kn-IN'));
      expect(codes, contains('ta-IN'));
      expect(codes, contains('te-IN'));
      expect(codes, contains('ml-IN'));
      expect(codes, contains('mr-IN'));
      expect(codes, contains('gu-IN'));
      expect(codes, contains('bn-IN'));
      expect(codes, contains('pa-IN'));
      expect(codes, contains('or-IN'));
      expect(codes, contains('as-IN'));
      expect(codes, contains('brx-IN'));
      expect(codes, contains('doi-IN'));
      expect(codes, contains('ks-IN'));
      expect(codes, contains('kok-IN'));
      expect(codes, contains('mai-IN'));
      expect(codes, contains('mni-IN'));
      expect(codes, contains('ne-IN'));
      expect(codes, contains('sa-IN'));
      expect(codes, contains('sat-IN'));
      expect(codes, contains('sd-IN'));
      expect(codes, contains('ur-IN'));
    });

    test('Correctly maps language codes and handles aliases', () {
      final kn = AppLanguage.fromCode('kn-IN');
      expect(kn.name, 'Kannada');
      expect(kn.nativeName, 'ಕನ್ನಡ');

      final hi = AppLanguage.fromCode('hi');
      expect(hi.name, 'Hindi');
      expect(hi.nativeName, 'हिन्दी');

      final od = AppLanguage.fromCode('od-IN');
      expect(od.name, 'Odia');

      final fallback = AppLanguage.fromCode('unknown');
      expect(fallback.code, 'en-IN');
    });
  });

  group('LanguageService & LocaleController Tests', () {
    test('Persists and restores language preference', () async {
      final service = LanguageService();
      expect(await service.hasSelectedLanguage(), false);

      final kn = AppLanguage.fromCode('kn-IN');
      await service.saveLanguage(kn);

      expect(await service.hasSelectedLanguage(), true);
      final restored = await service.getSavedLanguage();
      expect(restored.code, 'kn-IN');
    });

    test('LocaleController notifies listeners on language change', () async {
      final controller = LocaleController();
      bool notified = false;
      controller.addListener(() {
        notified = true;
      });

      final te = AppLanguage.fromCode('te-IN');
      await controller.setLanguage(te);

      expect(notified, true);
      expect(controller.currentLanguage.code, 'te-IN');
      expect(controller.locale.languageCode, 'te');
    });
  });

  group('Language Selection UI Tests', () {
    testWidgets('Renders all languages and handles search filtering',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LanguageSelectionScreen(isFirstLaunch: true),
        ),
      );

      // Verify header
      expect(find.text('Choose Your Language'), findsOneWidget);
      expect(find.text('Select your preferred language'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      // Search for "Kannada"
      await tester.enterText(find.byType(TextField), 'Kannada');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(LanguageCard, 'Kannada'), findsOneWidget);
      expect(find.text('ಕನ್ನಡ'), findsOneWidget);

      // Clear search
      await tester.tap(find.byIcon(Icons.clear_rounded));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
            (w) => w is LanguageCard && w.language.code == 'en-IN'),
        findsOneWidget,
      );
    });

    testWidgets('Selecting a language updates indicator and navigates on Continue',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LanguageSelectionScreen(isFirstLaunch: true),
        ),
      );

      // Tap on Kannada
      await tester.tap(find.text('ಕನ್ನಡ'));
      await tester.pumpAndSettle();

      // Selected indicator shows Kannada
      expect(find.text('Selected: '), findsOneWidget);
      expect(find.text('Kannada (ಕನ್ನಡ)'), findsOneWidget);

      // Tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Navigates to OnboardingScreen
      expect(find.byType(OnboardingScreen), findsOneWidget);
    });
  });

  group('AppLocalizations Translation Tests', () {
    testWidgets('Loads Kannada translations properly', (WidgetTester tester) async {
      late AppLocalizations l10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('kn', 'IN'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context)!;
              return Text(l10n.welcomeToKisanNetra);
            },
          ),
        ),
      );

      expect(find.text('ಕಿಸಾನ್ ನೇತ್ರಕ್ಕೆ ಸ್ವಾಗತ'), findsOneWidget);
      expect(l10n.login, 'ಲಾಗಿನ್');
      expect(l10n.register, 'ನೋಂದಾಯಿಸಿ');
    });

    testWidgets('Loads Hindi translations properly', (WidgetTester tester) async {
      late AppLocalizations l10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('hi', 'IN'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context)!;
              return Text(l10n.chooseYourLanguage);
            },
          ),
        ),
      );

      expect(find.byType(Text), findsOneWidget);
      expect(l10n.appName, 'CHIP TO CROP');
    });
  });
}
