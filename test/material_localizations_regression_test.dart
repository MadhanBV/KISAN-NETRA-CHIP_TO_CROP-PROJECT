import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chip_to_crop/core/localization/app_language.dart';
import 'package:chip_to_crop/core/localization/fallback_localizations_delegate.dart';
import 'package:chip_to_crop/features/auth/screens/register_phone_screen.dart';
import 'package:chip_to_crop/l10n/app_localizations.dart';

void main() {
  group('MaterialLocalizations Support for all 23 Official Languages', () {
    for (final lang in AppLanguage.supportedLanguages) {
      testWidgets('RegisterPhoneScreen renders seamlessly in ${lang.name} (${lang.code})',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: lang.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              FallbackMaterialLocalizationsDelegate(),
              FallbackCupertinoLocalizationsDelegate(),
              GlobalWidgetsLocalizations.delegate,
            ],
            home: const RegisterPhoneScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      });
    }
  });
}

