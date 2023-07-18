import 'package:whoops4/services/auth_user.dart';

import 'package:whoops4/services/auth_exception.dart';
import 'package:whoops4/services/auth/auth_provider.dart';

import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;


abstract class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<AuthUser> createUSer({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-password") {
        throw WeakPasswordFoundAuthException();
      } else if (e.code == "email-already-in-use") {
        throw EmailLAreadyInUserAuthException();
      } else if (e.code == "invalid-email") {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        throw UserNotFoundAuthException();
      } else if (e.code != password) {
        throw WrongPasswordFoundAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (e) {
      throw GenericAuthException();
    }
  }
}

@override
Future<void> logout() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await FirebaseAuth.instance.signOut();
  } else {
    throw UserNotFoundAuthException();
  }
}

@override
Future<void> sendEmailVerification() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await user.sendEmailVerification();
  } else {
    throw UserNotLoggedInAuthException();
  }
}
