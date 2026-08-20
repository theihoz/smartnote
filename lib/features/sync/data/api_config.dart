class ApiConfig {
  const ApiConfig(this.baseUrl);

  final String baseUrl;

  static ApiConfig? fromValue(String value) {
    final normalized = value.trim().replaceFirst(RegExp(r'/$'), '');
    final uri = Uri.tryParse(normalized);
    if (normalized.isEmpty ||
        uri == null ||
        !uri.hasScheme ||
        !uri.hasAuthority) {
      return null;
    }
    return ApiConfig(normalized);
  }

  static ApiConfig? fromEnvironment() {
    return fromValue(const String.fromEnvironment('API_BASE_URL'));
  }
}
