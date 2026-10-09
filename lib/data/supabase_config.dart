/// Supabase project settings, passed in at build time so no key is ever
/// committed to the repository:
///
/// ```bash
/// flutter run -d chrome --dart-define-from-file=supabase.json
/// ```
///
/// `supabase.json` is gitignored; copy `supabase.example.json` and fill in
/// the values from Supabase → Project Settings → API Keys. Only the public
/// publishable key (or the legacy `anon` key) belongs here, never a secret
/// or `service_role` key.
abstract final class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  /// Without both values the app falls back to the offline Hive store.
  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}
