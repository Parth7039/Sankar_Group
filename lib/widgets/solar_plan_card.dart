import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/solar_plan.dart';
import 'solar_plan_image.dart';

class SolarPlanCard extends StatelessWidget {
  const SolarPlanCard({
    required this.plan,
    required this.onTap,
    super.key,
  });

  final SolarPlan plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.surface,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'solar-plan-${plan.id}',
              child: SolarPlanImage(
                plan: plan,
                height: 142,
                showCategory: true,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      plan.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            height: 1.4,
                          ),
                    ),
                    const Spacer(),
                    if (plan.capacity != null) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            size: 16,
                            color: AppColors.solarGreenDark,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              plan.capacity!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        Text(
                          'View details',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppColors.burgundy,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: AppColors.burgundy,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
