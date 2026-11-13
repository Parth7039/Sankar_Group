import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/widgets/brand_mark.dart';
import '../core/widgets/primary_button.dart';
import '../core/widgets/section_heading.dart';


class SetupPreviewScreen extends StatelessWidget {
  const SetupPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BrandMark(compact: true),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.burgundy, AppColors.burgundyDark],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'CLEAN ENERGY. SMARTER LIVING.',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Power your future\nwith solar energy.',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 27,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Explore rooftop solar solutions from Mierae Solar.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.82),
                        ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const Icon(
                        Icons.wb_sunny_rounded,
                        color: Color(0xFFFFD36A),
                        size: 28,
                      ),
                      const SizedBox(width: 9),
                      Text(
                        'A brighter, cleaner tomorrow',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const SectionHeading(
              title: 'Design system preview',
              subtitle: 'Your brand colours and reusable components',
            ),
            const SizedBox(height: 16),
            const _ColourSwatches(),
            const SizedBox(height: 24),
            const SectionHeading(title: 'Reusable primary button'),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Explore solar solutions',
              icon: Icons.arrow_forward_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Design system is ready. Solar screens are coming next.',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Secondary button style is ready.'),
                  ),
                );
              },
              icon: const Icon(Icons.call_outlined),
              label: const Text('Contact Mierae Solar'),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.greenTint,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.solarGreen.withValues(alpha: 0.16)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.solarGreenDark,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Project setup and initial theme are ready.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.solarGreenDark,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColourSwatches extends StatelessWidget {
  const _ColourSwatches();

  @override
  Widget build(BuildContext context) {
    final swatches = [
      (label: 'Burgundy', hex: '#861B35', color: AppColors.burgundy),
      (label: 'Solar green', hex: '#359653', color: AppColors.solarGreen),
      (label: 'Background', hex: '#F7F8F6', color: AppColors.background),
      (label: 'Charcoal', hex: '#202521', color: AppColors.textPrimary),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 12,
      children: swatches.map((swatch) {
        return SizedBox(
          width: (MediaQuery.sizeOf(context).width - 50) / 2,
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: swatch.color,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      swatch.label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      swatch.hex,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
