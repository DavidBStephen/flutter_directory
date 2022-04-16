import 'package:directory/constants/status.dart';
import 'package:directory/modules/reset_password/bloc/reset_password_cubit.dart';
import 'package:directory/ui/widgets/text_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResetPasswordForm extends StatelessWidget {
  const ResetPasswordForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
        listener: (context, state) {
          if (state.status.isFailure) {
            var snackBar = SnackBar(
                content: Text(state.exceptionError),
                backgroundColor: Colors.red);
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } else if (state.status.isSuccess) {
            var snackBar = SnackBar(
              content: Text(AppLocalizations.of(context)!.passwordHasBeenReset),
              backgroundColor: Colors.green,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                        resetPasswordText(context),
                        emailInputField(),
                        resetPassword(),
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

  Widget resetPasswordText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0, top: 30.0),
      child: Text(
        AppLocalizations.of(context)!.forgotPassword,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget emailInputField() {
    return BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
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
                context.read<ResetPasswordCubit>().emailChanged(email),
          );
        });
  }

  Widget resetPassword() {
    return BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isValid != current.isValid,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: ElevatedButton(
            key: const Key('reset'),
            child: Text(AppLocalizations.of(context)!.reset),
            onPressed: state.isValid
                ? () async =>
                    await context.read<ResetPasswordCubit>().resetPassword()
                : null,
          ),
        );
      },
    );
  }
}
