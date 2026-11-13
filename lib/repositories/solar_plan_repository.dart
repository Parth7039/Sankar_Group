import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/app_config.dart';
import '../models/solar_plan.dart';

class SolarPlanRepository {
  Future<List<SolarPlan>> fetchActivePlans() async {
    if (!AppConfig.isSupabaseConfigured) {
      throw StateError(
        'Supabase is not configured. Add SUPABASE_URL and '
        'SUPABASE_PUBLISHABLE_KEY to supabase_config.json.',
      );
    }

    final rows = await Supabase.instance.client
        .from('solar_plans')
        .select(
          'id, name, category, description, capacity, image_url, features',
        )
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return rows
        .map<SolarPlan>((row) => SolarPlan.fromJson(row))
        .toList(growable: false);
  }
}
