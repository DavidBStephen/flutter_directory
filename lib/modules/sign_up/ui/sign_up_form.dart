import 'package:directory/constants/status.dart';
import 'package:directory/modules/sign_up/bloc/sign_up_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ui/widgets/text_input.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignUpCubit, SignUpState>(
        listener: (context, state) {
          if (state.status.isFailure) {
            var snackBar = SnackBar(
                content: Text(state.exceptionError),
                backgroundColor: Colors.red);
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } else if (state.status.isSuccess) {
            var snackBar = SnackBar(
              content: Text(AppLocalizations.of(context)!.accountCreated),
              backgroundColor: Colors.green,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            Navigator.of(context).pop(); // Return to home and navigate to list
          }
        },
        builder: (context, state) => Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(38.0, 0, 38.0, 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        signUpText(context),
                        emailInputField(),
                        passwordInputField(),
                        confirmInputField(),
                        signUp(),
                      ],
                    ),
                  ),
                ),
                state.status.inProgress
                    ? const Positioned(
                        child: Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Container(),
              ],
            ));
  }

  Widget signUpText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0, top: 30.0),
      child: Text(
        AppLocalizations.of(context)!.register,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget emailInputField() {
    return BlocBuilder<SignUpCubit, SignUpState>(
        buildWhen: (previous, current) =>
            previous.emailField.hasError != current.emailField.hasError,
        builder: (context, state) {
          return TextInput(
            key: const Key('email'),
            padding: const EdgeInsets.symmetric(vertical: 10),
            hint: AppLocalizations.of(context)!.email,
            keyboardType: TextInputType.emailAddress,
            initialValue: state.emailField.value,
            hasError: state.emailField.hasError,
            error: AppLocalizations.of(context)!.enterValidEmail,
            onChanged: (email) =>
                context.read<SignUpCubit>().emailChanged(email),
          );
        });
  }

  Widget passwordInputField() {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) =>
          previous.passwordField.hasError != current.passwordField.hasError,
      builder: (context, state) {
        return TextInput(
          key: const Key('password'),
          padding: const EdgeInsets.symmetric(vertical: 10),
          hint: AppLocalizations.of(context)!.password,
          isPasswordField: true,
          keyboardType: TextInputType.text,
          hasError: state.passwordField.hasError,
          error: AppLocalizations.of(context)!.enterValidPassword,
          onChanged: (password) =>
              context.read<SignUpCubit>().passwordChanged(password),
        );
      },
    );
  }

  Widget confirmInputField() {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) =>
          previous.confirmField.hasError != current.confirmField.hasError,
      builder: (context, state) {
        return TextInput(
          key: const Key('confirm'),
          padding: const EdgeInsets.symmetric(vertical: 10),
          hint: AppLocalizations.of(context)!.confirm,
          isPasswordField: true,
          keyboardType: TextInputType.text,
          hasError: state.confirmField.hasError,
          error: AppLocalizations.of(context)!.passwordDoesNotMatch,
          onChanged: (password) =>
              context.read<SignUpCubit>().confirmChanged(password),
        );
      },
    );
  }

  Widget signUp() {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isValid != current.isValid,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: ElevatedButton(
            key: const Key('signup'),
            child: Text(AppLocalizations.of(context)!.signUp),
            onPressed: state.isValid
                ? () async =>
                    await context.read<SignUpCubit>().signUpWithCredentials()
                : null,
          ),
        );
      },
    );
  }
}
