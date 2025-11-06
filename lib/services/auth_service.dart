import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sign up: creates auth user and a Firestore user doc with default role 'viewer'
  Future<UserCredential> signUp({
    required String email,
    required String password,
    String role = 'viewer', // default role
    String? adminSecret, // optional secret to assign admin at signup
  }) async {
    final uc = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final uid = uc.user!.uid;

    // If an admin secret is provided and matches your expected code, set role to admin.
    // IMPORTANT: For real apps, don't handle admin secrets client-side. This is okay for classes/demo.
    final assignedRole = (adminSecret != null && adminSecret == 'ADMIN_SECRET_123') ? 'admin' : role;

    await _db.collection('users').doc(uid).set({
      'email': email,
      'role': assignedRole,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return uc;
  }

  // Sign in
  Future<UserCredential> signIn({required String email, required String password}) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Sign out
  Future<void> signOut() async => await _auth.signOut();

  // Get current Firebase User
  User? get currentUser => _auth.currentUser;

  // Read role from Firestore for uid
  Future<String> getRoleForUid(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return 'viewer';
    final data = doc.data();
    if (data == null) return 'viewer';
    return (data['role'] as String?) ?? 'viewer';
  }

  // Stream for auth state changes
  Stream<User?> authStateChanges() => _auth.authStateChanges();
}
