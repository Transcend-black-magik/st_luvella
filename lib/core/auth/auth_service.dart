/// Firebase Authentication is the identity authority. Implementations return
/// an ID token that is forwarded to protected Supabase Edge Functions.
abstract interface class AuthService {
  Stream<AuthSession?> sessionChanges();
  Future<AuthSession> signInWithEmail(String email, String password);
  Future<AuthSession> registerWithEmail(String email, String password);
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
}

class AuthSession {
  const AuthSession({
    required this.firebaseUid,
    required this.idToken,
    required this.emailVerified,
  });
  final String firebaseUid;
  final String idToken;
  final bool emailVerified;
}
