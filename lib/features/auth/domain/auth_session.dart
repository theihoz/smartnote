enum AuthKind { guest, user }

class AuthSession {
  const AuthSession({
    required this.profileId,
    required this.kind,
    required this.accessToken,
    required this.expiresAt,
    this.email,
    this.guestSecret,
  });

  final String profileId;
  final AuthKind kind;
  final String accessToken;
  final DateTime expiresAt;
  final String? email;
  final String? guestSecret;

  Map<String, Object?> toJson() => {
    'profileId': profileId,
    'kind': kind.name,
    'accessToken': accessToken,
    'expiresAt': expiresAt.toUtc().toIso8601String(),
    'email': email,
    'guestSecret': guestSecret,
  };

  factory AuthSession.fromJson(Map<String, Object?> json) => AuthSession(
    profileId: json['profileId']! as String,
    kind: AuthKind.values.byName(json['kind']! as String),
    accessToken: json['accessToken']! as String,
    expiresAt: DateTime.parse(json['expiresAt']! as String),
    email: json['email'] as String?,
    guestSecret: json['guestSecret'] as String?,
  );
}
