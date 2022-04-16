import 'package:directory/modules/reset_password/bloc/reset_password_cubit.dart';
import 'package:directory/modules/reset_password/ui/reset_password_form.dart';
import 'package:directory/ui/widgets/simple_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({Key? key, required this.email}) : super(key: key);

  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(context: context),
      body: BlocProvider<ResetPasswordCubit>(
        create: (_) => ResetPasswordCubit(email: email),
        child: const ResetPasswordForm(),
      ),
    );
  }
}
