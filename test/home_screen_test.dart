import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chip_to_crop/app/main_app_shell.dart';
import 'package:chip_to_crop/core/constants/app_strings.dart';
import 'package:chip_to_crop/features/home/home_screen.dart';
import 'package:chip_to_crop/features/home/widgets/weather_card.dart';
import 'package:chip_to_crop/features/home/widgets/ai_service_card.dart';
import 'package:chip_to_crop/features/home/widgets/crop_tile.dart';
import 'package:chip_to_crop/features/home/widgets/leaf_disease_card.dart';
import 'package:chip_to_crop/features/home/widgets/quick_service_button.dart';
import 'package:chip_to_crop/features/community/community_screen.dart';
import 'package:chip_to_crop/features/crop_selling/crop_selling_screen.dart';
import 'package:chip_to_crop/features/marketplace/marketplace_screen.dart';
import 'package:chip_to_crop/features/profile/profile_screen.dart';
import 'package:chip_to_crop/shared/widgets/feature_placeholder_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: MainAppShell(),
    );
  }

  group('Home Screen UI Component Tests', () {
    testWidgets('Renders all required sections and components',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());

      // Header components
      expect(find.text(AppStrings.homeGreeting), findsOneWidget);
      expect(find.text(AppStrings.homeLocation), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsWidgets);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

      // Weather Card
      expect(find.byType(WeatherCard), findsOneWidget);
      expect(find.text('Weather & Farming Advisory'), findsOneWidget);

      // Flagship Leaf Disease Card
      expect(find.byType(LeafDiseaseCard), findsOneWidget);
      expect(find.text(AppStrings.leafDiseaseDetection), findsOneWidget);
      expect(find.text(AppStrings.leafDiseaseDetectionDesc), findsOneWidget);

      // Two Primary AI Service Cards
      expect(find.byType(AiServiceCard), findsNWidgets(2));
      expect(find.text(AppStrings.qualityDetection), findsOneWidget);
      expect(find.text(AppStrings.diseaseDetection), findsOneWidget);
      expect(find.text(AppStrings.qualityDetectionDesc), findsOneWidget);
      expect(find.text(AppStrings.diseaseDetectionDesc), findsOneWidget);

      // Supported Crops section
      expect(find.text(AppStrings.homeSupportedCrops), findsOneWidget);
      expect(find.byType(CropTile), findsNWidgets(4));
      expect(find.text(AppStrings.cropMango), findsOneWidget);
      expect(find.text(AppStrings.cropBanana), findsOneWidget);
      expect(find.text(AppStrings.cropTomato), findsOneWidget);
      expect(find.text(AppStrings.cropPotato), findsOneWidget);

      // Quick Services
      expect(find.text(AppStrings.homeQuickServices), findsOneWidget);
      expect(find.byType(QuickServiceButton), findsNWidgets(4));
    });

    testWidgets('Tapping Quality Detection navigates to Quality service screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text(AppStrings.qualityDetection));
      await tester.pumpAndSettle();

      expect(find.byType(FeaturePlaceholderScreen), findsOneWidget);
      expect(find.text('Scan your crop to check freshness and quality using AI.'),
          findsOneWidget);

      // Back navigation works
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Tapping Disease Detection navigates to Disease service screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text(AppStrings.diseaseDetection));
      await tester.pumpAndSettle();

      expect(find.byType(FeaturePlaceholderScreen), findsOneWidget);
      expect(
          find.text(
              'Identify crop diseases and infections with AI-powered analysis.'),
          findsOneWidget);

      // Back navigation works
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets(
        'Tapping Crop Plant Leaf Disease Detection navigates to Leaf Disease service screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text(AppStrings.leafDiseaseDetection));
      await tester.pumpAndSettle();

      expect(find.byType(FeaturePlaceholderScreen), findsOneWidget);
      expect(
          find.text(
              'Capture or upload a crop leaf image to identify diseases, analyze symptoms, and receive AI RAG-powered agricultural remedies.'),
          findsOneWidget);

      // Back navigation works
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Tapping Weather Card navigates to Weather service screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byType(WeatherCard));
      await tester.pumpAndSettle();

      expect(find.byType(FeaturePlaceholderScreen), findsOneWidget);
      expect(find.text('Live weather updates and smart farming guidance will appear here.'),
          findsOneWidget);
    });
  });

  group('WeatherCard States Test', () {
    testWidgets('Renders loading state properly without fake data',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherCard(state: WeatherState.loading),
          ),
        ),
      );

      expect(find.text(AppStrings.weatherLoading), findsOneWidget);
    });

    testWidgets('Renders unavailable state with retry action',
        (WidgetTester tester) async {
      bool retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeatherCard(
              state: WeatherState.unavailable,
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text(AppStrings.weatherUnavailable), findsOneWidget);
      expect(find.text(AppStrings.weatherRetry), findsOneWidget);

      await tester.tap(find.text(AppStrings.weatherRetry));
      expect(retried, isTrue);
    });

    testWidgets('Renders locationRequired state with set action',
        (WidgetTester tester) async {
      bool setLocationTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeatherCard(
              state: WeatherState.locationRequired,
              onSetLocation: () => setLocationTapped = true,
            ),
          ),
        ),
      );

      expect(find.text(AppStrings.weatherSetLocation), findsOneWidget);
      await tester.tap(find.text('Set'));
      expect(setLocationTapped, isTrue);
    });
  });

  group('Bottom Navigation Tests', () {
    testWidgets('Switches tabs correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Initial tab is Home
      expect(find.byType(HomeScreen), findsOneWidget);

      // Switch to Community
      await tester.tap(find.text(AppStrings.navCommunity));
      await tester.pumpAndSettle();
      expect(find.byType(CommunityScreen), findsOneWidget);

      // Switch to Sell
      await tester.tap(find.text(AppStrings.navSell));
      await tester.pumpAndSettle();
      expect(find.byType(CropSellingScreen), findsOneWidget);

      // Switch to Marketplace
      await tester.tap(find.text(AppStrings.navMarketplace));
      await tester.pumpAndSettle();
      expect(find.byType(MarketplaceScreen), findsOneWidget);

      // Switch to Profile
      await tester.tap(find.text(AppStrings.navProfile));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);

      // Switch back to Home
      await tester.tap(find.text(AppStrings.navHome));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
