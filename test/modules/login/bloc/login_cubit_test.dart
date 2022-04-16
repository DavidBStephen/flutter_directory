import 'package:bloc_test/bloc_test.dart';
import 'package:directory/modules/login/bloc/login_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

void main() {
  group('LoginCubit', () {
    setUpAll(() => registerLocator());
    tearDownAll(() => unregisterLocator());

    blocTest<LoginCubit, LoginState>('field error when email is empty',
        build: () => LoginCubit(),
        act: (cubit) => cubit.emailChanged(''),
        verify: (cubit) =>
            cubit.state.emailField.hasError && cubit.state.hasError);

    blocTest<LoginCubit, LoginState>('field error when email is invalid',
        build: () => LoginCubit(),
        act: (cubit) => cubit.emailChanged('bad_email'),
        verify: (cubit) =>
            cubit.state.emailField.hasError && cubit.state.hasError);

    blocTest<LoginCubit, LoginState>('field valid when email is valid',
        build: () => LoginCubit(),
        act: (cubit) => cubit.emailChanged('valid@email.com'),
        verify: (cubit) =>
            !cubit.state.emailField.hasError && cubit.state.hasError);

    blocTest<LoginCubit, LoginState>('field error when password is empty',
        build: () => LoginCubit(),
        act: (cubit) => cubit.passwordChanged(''),
        verify: (cubit) =>
            cubit.state.passwordField.hasError && cubit.state.hasError);

    blocTest<LoginCubit, LoginState>('field valid when password is valid',
        build: () => LoginCubit(),
        act: (cubit) => cubit.passwordChanged('password'),
        verify: (cubit) =>
            !cubit.state.emailField.hasError && cubit.state.hasError);

    blocTest<LoginCubit, LoginState>(
        'model valid when email and password is valid',
        build: () => LoginCubit(),
        act: (cubit) {
          cubit.emailChanged('valid@email.com');
          cubit.passwordChanged('password');
        },
        verify: (cubit) =>
            !cubit.state.emailField.hasError &&
            !cubit.state.passwordField.hasError &&
            !cubit.state.hasError);
  });
}
