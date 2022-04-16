import 'package:directory/modules/sign_up/bloc/sign_up_cubit.dart';
import 'package:directory/modules/sign_up/ui/sign_up_form.dart';
import 'package:directory/ui/widgets/simple_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class SignUpPage extends StatelessWidget {
  const SignUpPage({Key? key, required this.email}) : super(key: key);

  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(context: context),
      body: BlocProvider<SignUpCubit>(
        create: (_) => SignUpCubit(email: email),
        child: const SignUpForm(),
      ),
    );
  }
}
