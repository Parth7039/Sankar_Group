import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 18.0 : 23.0;
    final titleSize = compact ? 18.0 : 22.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 34 : 42,
          height: compact ? 34 : 42,
          decoration: BoxDecoration(
            color: AppColors.greenTint,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            Icons.solar_power_rounded,
            color: AppColors.solarGreen,
            size: iconSize,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'mierae',
              style: TextStyle(
                color: AppColors.solarGreenDark,
                fontSize: titleSize,
                fontWeight: FontWeight.w800,
                height: 1,
                letterSpacing: -0.7,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              'S O L A R',
              style: TextStyle(
                color: AppColors.burgundy,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.25,
                height: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
