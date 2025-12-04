import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Цей потік реагує ТІЛЬКИ на вхід/вихід
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Цей потік реагує на вхід/вихід А ТАКОЖ на оновлення токена
  Stream<User?> get userChanges => _firebaseAuth.userChanges();
 
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        await userCredential.user!.sendEmailVerification();
      }
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<UserCredential> signInWithGoogle() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
    
      googleProvider.setCustomParameters({
        'prompt': 'select_account'
      });

      return await _firebaseAuth.signInWithPopup(googleProvider);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user') {
        throw FirebaseAuthException(
            code: 'USER_CANCELLED',
            message: 'User cancelled the sign-in process');
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}