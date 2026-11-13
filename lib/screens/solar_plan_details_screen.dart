import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_contact.dart';
import '../models/solar_plan.dart';
import '../providers/solar_plan_provider.dart';
import '../widgets/solar_plan_image.dart';

class SolarPlanDetailsScreen extends ConsumerWidget {
  const SolarPlanDetailsScreen({required this.planId, super.key});

  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(solarPlansProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Solution details')),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 42),
                const SizedBox(height: 12),
                const Text('Unable to load this solar solution.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(solarPlansProvider),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
        data: (plans) {
          SolarPlan? selectedPlan;
          for (final plan in plans) {
            if (plan.id == planId) {
              selectedPlan = plan;
              break;
            }
          }

          if (selectedPlan == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_off_rounded, size: 42),
                    const SizedBox(height: 12),
                    Text(
                      'Solar solution not found',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => context.go('/plans'),
                      child: const Text('Back to solar solutions'),
                    ),
                  ],
                ),
              ),
            );
          }

          return _PlanDetailsContent(plan: selectedPlan);
        },
      ),
    );
  }
}

class _PlanDetailsContent extends StatelessWidget {
  const _PlanDetailsContent({required this.plan});

  final SolarPlan plan;

  Future<void> _openContact(BuildContext context, Uri uri) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the contact app.')),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the contact app.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Hero(
                    tag: 'solar-plan-${plan.id}',
                    child: SolarPlanImage(plan: plan, height: 230),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.greenTint,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    plan.categoryLabel.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.solarGreenDark,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                        ),
                  ),
                ),
                const SizedBox(height: 11),
                Text(plan.name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 9),
                Text(
                  plan.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55),
                ),
                if (plan.capacity != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppColors.greenTint,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt_rounded, color: AppColors.solarGreenDark),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Capacity information',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: AppColors.solarGreenDark,
                                    ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                plan.capacity!,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (plan.features.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Key features', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ...plan.features.map(
                    (feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 11),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 19,
                            color: AppColors.solarGreen,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              feature,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.burgundyTint,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.burgundy.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Interested in this solution?',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Contact the Mierae Solar team to discuss your property and requirements.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _openContact(
                                context,
                                Uri(scheme: 'tel', path: AppContact.phoneNumber),
                              ),
                              icon: const Icon(Icons.call_rounded, size: 18),
                              label: const Text('Call us'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.burgundy,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _openContact(
                                context,
                                Uri.https(
                                  'wa.me',
                                  '/${AppContact.whatsappNumber}',
                                  {
                                    'text': 'Hello Mierae Solar, I would like to know more about ${plan.name}.',
                                  },
                                ),
                              ),
                              icon: const Icon(Icons.chat_rounded, size: 18),
                              label: const Text('WhatsApp'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.solarGreenDark,
                                side: const BorderSide(color: AppColors.solarGreen),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
