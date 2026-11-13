import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/solar_plan.dart';
import '../repositories/solar_plan_repository.dart';

final solarPlanRepositoryProvider = Provider<SolarPlanRepository>((ref) {
  return SolarPlanRepository();
});

final solarPlansProvider = FutureProvider<List<SolarPlan>>((ref) {
  return ref.watch(solarPlanRepositoryProvider).fetchActivePlans();
});
