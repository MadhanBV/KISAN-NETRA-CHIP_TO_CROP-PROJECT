import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/empty_state_widget.dart';

/// Placeholder Marketplace tab screen.
/// Will be replaced with the full agricultural marketplace.
class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text(
          'Marketplace',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: const EmptyStateWidget(
        icon: Icons.shopping_bag_outlined,
        title: 'Agricultural Marketplace',
        description:
            'Browse seeds, fertilizers, machinery and farming supplies from trusted sellers.',
      ),
    );
  }
}

