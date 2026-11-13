import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_colors.dart';
import '../core/widgets/brand_mark.dart';


class SolarPlansComingSoonScreen extends StatelessWidget {
  const SolarPlansComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final category = GoRouterState.of(context).uri.queryParameters['category'];
    final categoryLabel = switch (category) {
      'residential' => 'Residential solar',
      'commercial' => 'Commercial solar',
      _ => 'Solar plans',
    };

    return Scaffold(
      appBar: AppBar(title: const BrandMark(compact: true)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: AppColors.greenTint,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.solar_power_rounded,
                    color: AppColors.solarGreen,
                    size: 43,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  categoryLabel,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 9),
                Text(
                  'The solar solutions catalogue is the next development step. For now, you can return to the home screen.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back to home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
