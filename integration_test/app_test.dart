import 'package:directory/config/dependencies.dart';
import 'package:directory/config/logging.dart';
import 'package:directory/core/auth/bloc/auth_cubit.dart';
import 'package:directory/main.dart' as app;
import 'package:directory/modules/contact/bloc/contact_cubit.dart';
import 'package:directory/modules/contacts/bloc/contacts_cubit.dart';
import 'package:directory/modules/contacts/ui/contacts_edit_button.dart';
import 'package:directory/modules/login/bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';

/// flutter test integration_test/app_test.dart

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ignore: constant_identifier_names
  const String TestEmail = 'test@servian.com';
  // ignore: constant_identifier_names
  const String TempEmail = 'temp@servian.com';
  // ignore: constant_identifier_names
  const String Password = 'Asdf1234!';

  const duration10 = Duration(seconds: 10);
  const duration30 = Duration(seconds: 30);

  Future<void> _loginTemp(String email) async {
    final loginCubit = LoginCubit();
    loginCubit.emailChanged(email);
    loginCubit.passwordChanged(Password);
    await loginCubit.logInWithCredentials();
  }

  Future<void> _forceLogout(WidgetTester tester) async {
    final authCubit = AuthCubit();
    await authCubit.signOut();
  }

  Future<void> _deleteTempContact() async {
    final contactsCubit = ContactsCubit();
    final contacts = await contactsCubit.getContacts(isConnected: true);
    for (var contact
        in contacts.records.where((element) => element.email == TempEmail)) {
      final contactCubit = ContactCubit(isNew: false, contact: contact);
      await contactCubit.deleteContact();
    }
  }

  Future<void> _initialize(WidgetTester tester, String message) async {
    logger.i('INITIALIZING : $message');
    await Firebase.initializeApp();
    await _forceLogout(tester);

    registerLocator();
    await _loginTemp(TestEmail);
    // clean up if needed
    await _deleteTempContact();

    // ensure signed out for test
    await _forceLogout(tester);

    logger.w('TESTING : $message');
    await app.main();

    await tester.pumpAndSettle(duration10);
    await tester.pumpAndSettle(duration10);
  }

  Future<void> _logout(WidgetTester tester) async {
    final menu = find.byKey(const Key('menu'));
    expect(menu, findsOneWidget);
    await tester.tap(menu);
    await tester.pumpAndSettle(duration10);
    final exit = find.byKey(const Key('exit'));
    expect(exit, findsOneWidget);
    await tester.tap(exit);
  }

  /// Tests ..................
  group('UI tests', () {
    setUp(() async {
      await GetIt.instance.reset();
    });
    testWidgets('sign up', (WidgetTester tester) async {
      await _initialize(tester, 'sign up');

      final loginEmail = find.byKey(const Key('email'));
      expect(loginEmail, findsOneWidget);
      await tester.enterText(loginEmail, TempEmail);
      await tester.pumpAndSettle(duration10);

      final loginSignup = find.byKey(const Key('signup'));
      expect(loginSignup, findsOneWidget);
      await tester.tap(loginSignup);
      await tester.pumpAndSettle(duration10); // Should be on sign up screen

      // Email should have come across from login screen - checking value
      final email = find.text(TempEmail);

      expect(email, findsOneWidget);

      final password = find.byKey(const Key('password'));
      expect(password, findsOneWidget);
      await tester.enterText(password, Password);
      final confirm = find.byKey(const Key('confirm'));
      expect(confirm, findsOneWidget);
      await tester.enterText(confirm, Password);
      await tester.pumpAndSettle();

      final signup = find.byKey(const Key('signup'));
      expect(signup, findsOneWidget);
      await tester.tap(signup);
      await tester.pumpAndSettle(duration10);

      // Logout
      await _logout(tester);
      await tester.pumpAndSettle(duration10);
    });

    testWidgets('forgot password', (WidgetTester tester) async {
      await _initialize(tester, 'forgot password');

      final loginEmail = find.byKey(const Key('email'));
      expect(loginEmail, findsOneWidget);
      await tester.enterText(loginEmail, TestEmail);
      await tester.pumpAndSettle(duration10);

      final loginForgotPassword = find.byKey(const Key('forgotpassword'));
      expect(loginForgotPassword, findsOneWidget);
      await tester.tap(loginForgotPassword);
      await tester.pumpAndSettle(duration10); // Should be on sign up screen

      // Email should have come across from login screen - checking value
      final email = find.text(TestEmail);
      expect(email, findsOneWidget);

      final reset = find.byKey(const Key('reset'));
      expect(reset, findsOneWidget);
      await tester.tap(reset);

      await tester.pumpAndSettle(duration10);
    });

    testWidgets('end-to-end', (WidgetTester tester) async {
      await _initialize(tester, 'end-to-end');

      final loginEmail = find.byKey(const Key('email'));
      expect(loginEmail, findsOneWidget);
      await tester.enterText(loginEmail, TestEmail);
      await tester.pumpAndSettle();

      final loginPassword = find.byKey(const Key('password'));
      expect(loginPassword, findsOneWidget);
      await tester.enterText(loginPassword, Password);
      await tester.pumpAndSettle();

      final login = find.byKey(const Key('login'));
      expect(login, findsOneWidget);
      await tester.tap(login);
      await tester.pumpAndSettle(duration30); // Should be on main list

      // Test create record
      final newContact = find.byKey(const Key('newcontact'));
      expect(newContact, findsOneWidget);
      await tester.tap(newContact);
      await tester.pumpAndSettle(duration10); // Should be on details screen

      // Create temp user
      final firstName = find.byKey(const Key('firstname'));
      expect(firstName, findsOneWidget);
      await tester.enterText(firstName, 'Temp');
      await tester.pumpAndSettle();
      final lastName = find.byKey(const Key('lastname'));
      expect(lastName, findsOneWidget);
      await tester.enterText(lastName, 'Temp');
      await tester.pumpAndSettle();
      final email = find.byKey(const Key('email'));
      expect(email, findsOneWidget);
      await tester.enterText(email, TempEmail);
      await tester.pumpAndSettle();
      final phone = find.byKey(const Key('phone'));
      expect(phone, findsOneWidget);
      await tester.enterText(phone, '0000 000 000');
      await tester.pumpAndSettle();
      final role = find.byKey(const Key('role'));
      expect(role, findsOneWidget);
      await tester.enterText(role, 'role');
      await tester.pumpAndSettle();
      final save = find.byKey(const Key('save'));
      expect(save, findsOneWidget);
      await tester.tap(save);
      await tester.pumpAndSettle(duration10); // Should be on xxxx screen

      // Test can see record and check new record (TempEmail)
      final editButtons = find.byElementPredicate((element) {
        var widget = element.widget;
        if (widget is ContactsEditButton) {
          return (widget.contact.email == TempEmail);
        }
        return false;
      });
      expect(editButtons, findsOneWidget);

      // Edit page
      await tester.tap(editButtons);
      await tester.pumpAndSettle(duration30);
      // Delete button
      final delete = find.byKey(const Key('delete'));
      await tester.tap(delete);
      await tester.pumpAndSettle(duration30);
      // OK from confirmation
      final ok = find.text('Ok'); // Ok button
      await tester.tap(ok);
      await tester.pumpAndSettle(duration30);

      // Test new record gone (TempEmail)
      final editButtons2 = find.byElementPredicate((element) {
        var widget = element.widget;
        if (widget is ContactsEditButton) {
          return (widget.contact.email == TempEmail);
        }
        return false;
      });
      expect(editButtons2, findsNothing);

      await tester.pumpAndSettle(duration10);
      // Logout
      await _logout(tester);
    });
  });
}
