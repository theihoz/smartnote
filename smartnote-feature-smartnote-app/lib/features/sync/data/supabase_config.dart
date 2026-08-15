class SupabaseConfig {
  const SupabaseConfig({required this.url, required this.publishableKey});

  final String url;
  final String publishableKey;

  static SupabaseConfig? fromValues({
    required String url,
    required String publishableKey,
  }) {
    final normalizedUrl = url.trim();
    final normalizedKey = publishableKey.trim();
    if (normalizedUrl.isEmpty || normalizedKey.isEmpty) return null;
    return SupabaseConfig(url: normalizedUrl, publishableKey: normalizedKey);
  }

  static SupabaseConfig? fromEnvironment() {
    return fromValues(
      url: const String.fromEnvironment('SUPABASE_URL'),
      publishableKey: const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
    );
  }
}
