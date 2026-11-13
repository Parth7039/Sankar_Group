abstract final class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static const hasAnySupabaseValue =
      supabaseUrl != '' || supabasePublishableKey != '';
  static const isSupabaseConfigured =
      supabaseUrl != '' && supabasePublishableKey != '';
}
