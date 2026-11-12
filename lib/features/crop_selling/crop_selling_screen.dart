import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/empty_state_widget.dart';

/// Placeholder Crop Selling tab screen.
/// Will be replaced with the full crop listing flow.
class CropSellingScreen extends StatelessWidget {
  const CropSellingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text(
          'Sell Crops',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primaryGreen),
            onPressed: () {},
            tooltip: 'List a crop',
          ),
        ],
      ),
      body: const EmptyStateWidget(
        icon: Icons.storefront_outlined,
        title: 'Your Crop Listings',
        description:
            'List your harvested crops and connect directly with buyers.',
      ),
    );
  }
}

