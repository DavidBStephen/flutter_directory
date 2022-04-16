import 'package:directory/modules/login/ui/login_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Global locator
GetIt locator = GetIt.instance;

@GenerateMocks([FirebaseAuth, FlutterSecureStorage])
class FirebaseAuthMock extends Mock implements FirebaseAuth {}

class FlutterSecureStorageMock extends Mock implements FlutterSecureStorage {}

void registerLocator() {
  locator.registerFactory<FirebaseAuth>(() => FirebaseAuthMock());
  locator
      .registerFactory<FlutterSecureStorage>(() => FlutterSecureStorageMock());
}

void unregisterLocator() {
  locator.unregister<FirebaseAuth>();
  locator.unregister<FlutterSecureStorage>();
}

Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  registerLocator();
}

Widget createWidgetForTesting({required Widget child}) {
  return MaterialApp(
    home: child,
  );
}

void main() {
  group('LoginForm', () {
    setUpAll(() async => await init());
    tearDownAll(() => unregisterLocator());

    testWidgets('Login form test', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetForTesting(
          child: LoginForm(
              enableExternalLogin:
                  false))); // Issue with google signin button so hiding for tests
      await tester.pumpAndSettle();

      final loginButton = find.byKey(const Key('login'));
      expect(loginButton, findsOneWidget);
      // Login should not be enabled
      var loginButtonWidget = tester.widget(loginButton) as ElevatedButton;
      assert(loginButtonWidget.onPressed == null);

      // Verify that email and password
      final emailField = find.byKey(const Key('email'));
      expect(emailField, findsOneWidget);
      await tester.enterText(emailField, 'test@email.com');
      await tester.pumpAndSettle();
      // Login should not be enabled
      loginButtonWidget = tester.widget(loginButton) as ElevatedButton;
      assert(loginButtonWidget.onPressed == null);

      final passwordField = find.byKey(const Key('password'));
      expect(passwordField, findsOneWidget);
      await tester.enterText(passwordField, 'password');
      await tester.pumpAndSettle();

      // Check can login
      loginButtonWidget = tester.widget(loginButton) as ElevatedButton;
      assert(loginButtonWidget.onPressed != null);
    });
  });
}
