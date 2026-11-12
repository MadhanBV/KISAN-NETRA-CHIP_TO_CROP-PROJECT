import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chip_to_crop/core/constants/app_strings.dart';
import 'package:chip_to_crop/features/mandi/models/mandi_models.dart';
import 'package:chip_to_crop/features/mandi/widgets/mandi_card.dart';
import 'package:chip_to_crop/features/mandi/widgets/location_selector_sheet.dart';
import 'package:chip_to_crop/features/mandi/screens/mandi_prices_screen.dart';

void main() {
  group('Mandi Models Tests', () {
    test('MandiRecord parses valid government API response correctly', () {
      final json = {
        'state': 'Karnataka',
        'district': 'Davangere',
        'market': 'Davangere APMC',
        'commodity': 'Groundnut',
        'variety': 'Hybrid',
        'grade': 'FAQ',
        'arrival_date': '02/11/2026',
        'min_price': 6060,
        'max_price': 9120,
        'modal_price': 8493,
        'commodity_code': 'GND',
        'raw': {'state': 'Karnataka', 'district': 'Davangere'}
      };

      final record = MandiRecord.fromJson(json);

      expect(record.state, 'Karnataka');
      expect(record.district, 'Davangere');
      expect(record.market, 'Davangere APMC');
      expect(record.commodity, 'Groundnut');
      expect(record.minPrice, 6060.0);
      expect(record.maxPrice, 9120.0);
      expect(record.modalPrice, 8493.0);
      expect(record.arrivalDate, '02/11/2026');
    });

    test('MandiRecord handles missing or null prices without inventing ₹0', () {
      final json = {
        'state': 'Maharashtra',
        'district': 'Pune',
        'market': 'Pune Mandi',
        'commodity': 'Onion',
        'variety': 'Red',
        'arrival_date': '02/11/2026',
        'min_price': null,
        'max_price': null,
        'modal_price': null,
      };

      final record = MandiRecord.fromJson(json);

      expect(record.minPrice, isNull);
      expect(record.maxPrice, isNull);
      expect(record.modalPrice, isNull);
    });

    test('MandiResponse parses envelope and metadata for resource 9ef84268', () {
      final json = {
        'success': true,
        'source': 'data.gov.in',
        'resource_id': '9ef84268-d588-465a-a308-a864a43d0070',
        'total_records': 1,
        'count': 1,
        'limit': 20,
        'offset': 0,
        'records': [
          {
            'state': 'Karnataka',
            'district': 'Davangere',
            'market': 'Davangere APMC',
            'commodity': 'Groundnut',
            'variety': 'Hybrid',
            'arrival_date': '02/11/2026',
            'modal_price': 8493,
          }
        ],
      };

      final response = MandiResponse.fromJson(json);
      expect(response.success, isTrue);
      expect(response.totalRecords, 1);
      expect(response.records.length, 1);
      expect(response.records.first.market, 'Davangere APMC');
    });
  });

  group('MandiPriceCard Widget Tests', () {
    testWidgets('Renders clean price card with modal price, min/max range, and arrival date',
        (WidgetTester tester) async {
      final record = MandiRecord(
        state: 'Karnataka',
        district: 'Davangere',
        market: 'Davangere APMC',
        commodity: 'Groundnut',
        variety: 'Hybrid',
        arrivalDate: '02/11/2026',
        minPrice: 6060,
        maxPrice: 9120,
        modalPrice: 8493,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MandiPriceCard(record: record),
          ),
        ),
      );

      // Verify Market, District, State
      expect(find.text('Davangere APMC'), findsOneWidget);
      expect(find.text('Davangere, Karnataka'), findsOneWidget);

      // Verify Modal price
      expect(find.text('₹8,493'), findsOneWidget);
      expect(find.text('/ Quintal'), findsOneWidget);

      // Verify Min & Max range
      expect(find.text('₹6,060'), findsOneWidget);
      expect(find.text('₹9,120'), findsOneWidget);

      // Verify Arrival Date badge
      expect(find.text('02/11/2026'), findsWidgets);
    });

    testWidgets('Renders price card when modal price is unavailable',
        (WidgetTester tester) async {
      final record = MandiRecord(
        state: 'Karnataka',
        district: 'Bangalore',
        market: 'Remote Market',
        commodity: 'Potato',
        variety: 'Jyoti',
        arrivalDate: '02/11/2026',
        modalPrice: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MandiPriceCard(record: record),
          ),
        ),
      );

      expect(find.text('Unavailable'), findsNWidgets(3));
      expect(find.text('02/11/2026'), findsWidgets);
    });
  });

  group('LocationSelectorSheet Widget Tests', () {
    testWidgets('Renders state and district selections and handles confirmation',
        (WidgetTester tester) async {
      String? selectedStateResult;
      String? selectedDistrictResult;

      final states = [
        StateDistrictsInfo(
          state: 'Karnataka',
          districts: ['Bangalore', 'Davangere', 'Kolar'],
        ),
        StateDistrictsInfo(
          state: 'Maharashtra',
          districts: ['Mumbai', 'Pune', 'Nashik'],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationSelectorSheet(
              currentState: 'Karnataka',
              currentDistrict: 'All Districts',
              statesList: states,
              onLocationSelected: (state, district) {
                selectedStateResult = state;
                selectedDistrictResult = district;
              },
            ),
          ),
        ),
      );

      expect(find.text('Select Mandi Location'), findsOneWidget);
      expect(find.text('Karnataka'), findsWidgets);
      expect(find.text('All Districts'), findsWidgets);

      // Tap apply button
      await tester.tap(find.text('Apply Location'));
      await tester.pumpAndSettle();

      expect(selectedStateResult, 'Karnataka');
      expect(selectedDistrictResult, 'All Districts');
    });
  });

  group('MandiPricesScreen Structure Tests', () {
    testWidgets('Renders simplified Mandi Prices Screen layout with state selector and crop filters',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: MandiPricesScreen(initialCommodity: 'Groundnut'),
        ),
      );

      // Screen title
      expect(find.text(AppStrings.mandiPricesTitle), findsOneWidget);

      // Simple Location selector card
      expect(find.byIcon(Icons.location_on_rounded), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);
      expect(find.text('Tap to change state or district'), findsOneWidget);

      // Search input
      expect(find.byType(TextField), findsOneWidget);

      // Crop chips
      expect(find.text('🌾 All'), findsOneWidget);
      expect(find.text('🥜 Groundnut'), findsOneWidget);
      expect(find.text('🌽 Maize'), findsOneWidget);

      // Sort button
      expect(find.text('Sort'), findsOneWidget);
    });
  });
}
