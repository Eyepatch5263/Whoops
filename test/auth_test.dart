import 'package:flutter_test/flutter_test.dart';
import 'package:whoops4/services/auth/auth_provider.dart';
import 'package:whoops4/services/auth_exception.dart';
import 'package:whoops4/services/auth_user.dart';

void main() {
  group("Mock Authentication", () {
    final provider = MockAuthProvider();
    test("Should not be Initialized to begin with", () {
      expect(provider.isInitialized, false);
    });

    test("Cannot logout if not Initialized ", () {
      expect(provider.logout(),
          throwsA(const TypeMatcher<NotInitializedException>()));
    });

    test("Should be able to be initialized", () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test("User should be null after initialization", () {
      expect(provider.currentUser, null);
    });

    test(
      "should be able to initialize in less than 2 seconds",
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    test("Create user should delegate to Login function", () async {
      final badEmailUser = provider.createUSer(
        email: "foo@bar.com",
        password: "anypassword",
      );
      expect(badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final badPasswordUser = provider.createUSer(
        email: "someone@bar.com",
        password: "foobar",
      );
      expect(badPasswordUser,
          throwsA(const TypeMatcher<WrongPasswordFoundAuthException>()));

      final user = await provider.createUSer(
        email: "foo",
        password: "bar",
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test("Logged in user should be able to verify", () {
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, false);
    });

    test("Should be able to logout and login again", () async {
      await provider.logout();
      await provider.logIn(email: "email", password: "password");
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUSer({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if (!isInitialized) throw NotInitializedException();
    if (email == "foor@bar.com") throw UserNotFoundAuthException();
    if (password == "foobar") throw WrongPasswordFoundAuthException();
    const user = AuthUser(isEmailVerified: false, email: '');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logout() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true, email: '');
    _user = newUser;
  }
}
