import 'package:directory/core/auth/bloc/auth_cubit.dart';
import 'package:directory/core/connectivity/bloc/connectivity_cubit.dart';
import 'package:directory/modules/login/ui/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../modules/contacts/ui/contacts_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      lazy: false,
      create: (BuildContext context) => AuthCubit(),
      child: BlocProvider<ConnectivityCubit>(
        lazy: false,
        create: (BuildContext context) => ConnectivityCubit(),
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state.isSignedIn) {
              return const ContactsPage();
            } else {
              return LoginForm();
            }
          },
        ),
      ),
    );
  }
}
