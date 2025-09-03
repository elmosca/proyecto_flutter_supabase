import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/auth_service.dart';

void main() {
  group('Backend Connection Tests', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('AuthService can be instantiated', () {
      expect(authService, isNotNull);
      expect(authService, isA<AuthService>());
    });

    test('AuthService has required methods', () {
      expect(authService.signIn, isA<Function>());
      expect(authService.signOut, isA<Function>());
      expect(authService.getCurrentUserProfile, isA<Function>());
    });

    test('AuthService has required properties', () {
      expect(authService.currentUser, isA<dynamic>());
      expect(authService.authStateChanges, isA<Stream>());
      expect(authService.isAuthenticated, isA<bool>());
    });
  });
}
