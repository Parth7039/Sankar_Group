import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.hasAnySupabaseValue && !AppConfig.isSupabaseConfigured) {
    throw StateError(
      'Both SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY must be provided. '
      'See STEP_2_AUTH_SETUP.md.',
    );
  }

  if (AppConfig.isSupabaseConfigured) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabasePublishableKey,
    );
  }

  runApp(const ProviderScope(child: MieraeSolarApp()));
}
