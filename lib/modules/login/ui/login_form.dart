import 'package:directory/core/connectivity/bloc/connectivity_cubit.dart';
import 'package:directory/modules/login/bloc/bloc.dart';
import 'package:directory/modules/reset_password/ui/reset_password_page.dart';
import 'package:directory/modules/sign_up/ui/sign_up_page.dart';
import 'package:directory/ui/widgets/text_input.dart';
import 'package:directory/ui/widgets/simple_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../ui/widgets/no_internet_connection.dart';

class LoginForm extends StatelessWidget {
  LoginForm({Key? key, this.enableExternalLogin = true}) : super(key: key) {
    _loginCubit = LoginCubit();
  }

  late final LoginCubit _loginCubit;
  final bool enableExternalLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(context: context),
      body: BlocBuilder<ConnectivityCubit, ConnectivityState>(
        builder: (context, connectivity) => FutureBuilder<void>(
            future: _loginCubit.loadCredentials(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Container();
              }
              return BlocProvider<LoginCubit>(
                lazy: false,
                create: (context) => _loginCubit,
                child: BlocConsumer<LoginCubit, LoginState>(
                  listener: (context, state) {
                    if (state.status.isFailure) {
                      var snackBar = SnackBar(
                        content: Text(state.exceptionError),
                        backgroundColor: Colors.red,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                  builder: (context, state) {
                    return Stack(
                      children: [
                        !state.status.inProgress
                            ? Positioned.fill(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.fromLTRB(
                                      38.0, 0, 38.0, 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      loginText(context),
                                      emailInputField(),
                                      passwordInputField(),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: signUpButton(
                                                  context,
                                                  state.emailField.value,
                                                  connectivity.isConnected)),
                                          Expanded(
                                              child: login(
                                                  connectivity.isConnected)),
                                          Expanded(
                                              child: forgotPassword(
                                                  context,
                                                  state.emailField.value,
                                                  connectivity.isConnected))
                                        ],
                                      ),
                                      if (!connectivity.isConnected)
                                        const NoInternetConnection(),
                                      if (enableExternalLogin &&
                                          connectivity.isConnected)
                                        Column(
                                          children: [
                                            separatedText(context),
                                            signInWithGoogle(),
                                            // signInWithGithub(),
                                            // signInWithTwitter(),
                                            // signInWithApple(),
                                            // signInWithMicrosoft(),
                                          ],
                                        )
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                        state.status.inProgress
                            ? const Positioned(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : Container(),
                      ],
                    );
                  },
                ),
              );
            }),
      ),
    );
  }

  Widget loginText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0, top: 30.0),
      child: Text(
        AppLocalizations.of(context)!.loginViaEmail,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget separatedText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
      child: Text(
        AppLocalizations.of(context)!.or,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget emailInputField() {
    return BlocBuilder<LoginCubit, LoginState>(
        buildWhen: (previous, current) =>
            previous.emailField.hasError != current.emailField.hasError,
        builder: (context, state) {
          final t = AppLocalizations.of(context)!;
          return TextInput(
            key: const Key('email'),
            hint: t.email,
            keyboardType: TextInputType.emailAddress,
            initialValue: state.emailField.value,
            hasError: state.emailField.hasError,
            error: t.enterValidEmail,
            onChanged: (email) =>
                context.read<LoginCubit>().emailChanged(email),
          );
        });
  }

  Widget passwordInputField() {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) =>
          previous.passwordField != current.passwordField,
      builder: (context, state) {
        final t = AppLocalizations.of(context)!;
        return TextInput(
          key: const Key('password'),
          padding: const EdgeInsets.symmetric(vertical: 20),
          hint: t.password,
          isPasswordField: true,
          initialValue: state.passwordField.value,
          keyboardType: TextInputType.text,
          hasError: state.passwordField.hasError,
          error: t.enterValidPassword,
          onChanged: (password) =>
              context.read<LoginCubit>().passwordChanged(password),
        );
      },
    );
  }

  Widget login(bool isEnabled) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isValid != current.isValid,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(top: 15),
          child: ElevatedButton(
              key: const Key('login'),
              onPressed: state.isValid && isEnabled
                  ? () async =>
                      await context.read<LoginCubit>().logInWithCredentials()
                  : null,
              child: Text(AppLocalizations.of(context)!.login)),
        );
      },
    );
  }

  Widget signUpButton(BuildContext context, String email, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, right: 5),
      child: ElevatedButton(
          key: const Key('signup'),
          onPressed: isEnabled
              ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SignUpPage(email: email)),
                  )
              : null,
          child: Text(AppLocalizations.of(context)!.signUp)),
    );
  }

  Widget forgotPassword(BuildContext context, String email, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 5),
      child: ElevatedButton(
          key: const Key('forgotpassword'),
          onPressed: isEnabled
              ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ResetPasswordPage(email: email)),
                  )
              : null,
          child: Text(AppLocalizations.of(context)!.forgot)),
    );
  }

  Widget signInWithGoogle() {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return Padding(
            padding: const EdgeInsets.only(top: 5),
            child: SignInButton(Buttons.Google,
                onPressed: () =>
                    context.read<LoginCubit>().signInWithGoogle()));
      },
    );
  }

  Widget signInWithGithub() {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SignInButton(Buttons.GitHub,
                onPressed: () =>
                    context.read<LoginCubit>().signInWithGithub()));
      },
    );
  }

  Widget signInWithTwitter() {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SignInButton(Buttons.Twitter,
                onPressed: () =>
                    context.read<LoginCubit>().signInWithTwitter()));
      },
    );
  }

  Widget signInWithApple() {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SignInButton(Buttons.Apple,
                onPressed: () => context.read<LoginCubit>().signInWithApple()));
      },
    );
  }

  Widget signInWithMicrosoft() {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SignInButton(Buttons.Microsoft,
                onPressed: () =>
                    context.read<LoginCubit>().signInWithMicrosoft()));
      },
    );
  }
}
