import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/solar_plan.dart';

class SolarPlanImage extends StatelessWidget {
  const SolarPlanImage({
    required this.plan,
    required this.height,
    this.showCategory = false,
    super.key,
  });

  final SolarPlan plan;
  final double height;
  final bool showCategory;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (plan.imageUrl != null)
            CachedNetworkImage(
              imageUrl: plan.imageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => _placeholder(),
              errorWidget: (context, url, error) => _placeholder(),
            )
          else
            _placeholder(),
          if (showCategory)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  plan.categoryLabel.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.solarGreenDark,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.65,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.greenTint, AppColors.burgundyTint],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.solar_power_rounded,
          size: 58,
          color: AppColors.solarGreenDark.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}
