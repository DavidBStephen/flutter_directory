import 'dart:convert';
import 'package:directory/constants/activity.dart';
import 'package:directory/core/connectivity/bloc/connectivity_cubit.dart';
import 'package:directory/models/contact.dart';
import 'package:directory/modules/contact/bloc/contact_cubit.dart';
import 'package:directory/ui/widgets/text_input.dart';
import 'package:directory/ui/widgets/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:directory/constants/status.dart';
import 'package:loading_overlay/loading_overlay.dart';
import '../../../config/logging.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../ui/widgets/no_internet_connection.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key, required this.contact, required this.isNew})
      : super(key: key);

  final Contact contact;
  final bool isNew;

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> with RestorationMixin {
  late final RestorableString _contact;
  ContactState? _currentState;
  bool _isLoading = false;

  @override
  void initState() {
    _contact = RestorableString(_encodeContact(widget.contact));
    super.initState();
  }

  String _encodeContact(Contact contact) =>
      jsonEncode(contact.toMap(isNew: widget.isNew));

  @override
  String? get restorationId => "contact_screen";

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_contact, "contact");
  }

  @override
  void dispose() {
    super.dispose();
    _contact.dispose();
  }

  Future<bool> _canCancel() async {
    if (_currentState?.hasChanged ?? false) {
      final result = await showDialog(
          context: context,
          builder: (context) {
            final t = AppLocalizations.of(context)!;
            return AlertDialog(
              title: Text(t.cancelChanges),
              content: Text(t.cancelChangesMessage),
              actions: <Widget>[
                ElevatedButton(
                    child: Text(t.yes),
                    onPressed: () => Navigator.of(context).pop(true)),
                ElevatedButton(
                    child: Text(t.no),
                    onPressed: () => Navigator.of(context).pop(false)),
              ],
            );
          });
      return result;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final json = jsonDecode(_contact.value);
    final isNew = json['isNew'] as bool;
    final contact = Contact.fromMap(json);
    return Scaffold(
      appBar: MainAppBar(context: context),
      body: WillPopScope(
        onWillPop: () => _canCancel(),
        child: BlocProvider<ContactCubit>(
          lazy: false,
          create: (_) => ContactCubit(contact: contact, isNew: isNew),
          child: BlocListener<ContactCubit, ContactState>(
            listener: (context, state) {
              _currentState = state;
              _contact.value = _encodeContact(state.contact);
              setState(() {
                _isLoading = state.status.inProgress;
              });
              final t = AppLocalizations.of(context)!;
              if (state.status.isSuccess) {
                final message =
                    state.activity.isUpdate ? t.contactSaved : t.contactDeleted;
                _showSnackBar(context, true, message);
                Navigator.of(context).pop(contact);
              } else if (state.status.isFailure) {
                final message = state.activity.isUpdate
                    ? t.contactSaveError
                    : t.contactDeleteError;
                _showSnackBar(context, false, message);
              }
            },
            child: LoadingOverlay(
              isLoading: _isLoading,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(38.0, 0, 38.0, 8.0),
                child: BlocProvider<ConnectivityCubit>(
                  create: (context) => ConnectivityCubit(),
                  child: BlocBuilder<ConnectivityCubit, ConnectivityState>(
                    builder: (context, connectivity) => Column(
                      children: [
                        firstNameInputField(context, connectivity.isConnected),
                        lastNameInputField(context, connectivity.isConnected),
                        emailInputField(context, connectivity.isConnected),
                        phoneInputField(context, connectivity.isConnected),
                        roleInputField(context, connectivity.isConnected),
                        Row(
                          children: [
                            saveButton(connectivity.isConnected),
                            deleteButton(connectivity.isConnected),
                          ],
                        ),
                        if (!connectivity.isConnected)
                          const NoInternetConnection(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, bool success, String message) {
    final snackBar = SnackBar(
      backgroundColor: success ? Colors.green : Colors.red,
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget firstNameInputField(BuildContext context, bool isEnabled) {
    return BlocBuilder<ContactCubit, ContactState>(
        buildWhen: (previous, current) =>
            previous.firstNameField != current.firstNameField,
        builder: (context, state) {
          final t = AppLocalizations.of(context)!;
          return TextInput(
            key: const Key('firstname'),
            hint: t.firstName,
            keyboardType: TextInputType.name,
            initialValue: state.firstNameField.value,
            hasError: state.firstNameField.hasError,
            error: t.enterValidFirstName,
            enabled: isEnabled,
            onChanged: (value) =>
                context.read<ContactCubit>().firstNameChanged(value),
          );
        });
  }

  Widget lastNameInputField(BuildContext context, bool isEnabled) {
    return BlocBuilder<ContactCubit, ContactState>(
        buildWhen: (previous, current) =>
            previous.lastNameField != current.lastNameField,
        builder: (context, state) {
          final t = AppLocalizations.of(context)!;
          return TextInput(
            key: const Key('lastname'),
            hint: t.lastName,
            keyboardType: TextInputType.name,
            initialValue: state.lastNameField.value,
            hasError: state.lastNameField.hasError,
            error: t.enterValidLastName,
            enabled: isEnabled,
            onChanged: (value) =>
                context.read<ContactCubit>().lastNameChanged(value),
          );
        });
  }

  Widget emailInputField(BuildContext context, bool isEnabled) {
    return BlocBuilder<ContactCubit, ContactState>(
        buildWhen: (previous, current) =>
            previous.emailField != current.emailField,
        builder: (context, state) {
          final t = AppLocalizations.of(context)!;
          return TextInput(
            key: const Key('email'),
            hint: t.email,
            keyboardType: TextInputType.emailAddress,
            initialValue: state.emailField.value,
            hasError: state.emailField.hasError,
            error: t.enterValidEmail,
            enabled: isEnabled,
            onChanged: (value) =>
                context.read<ContactCubit>().emailChanged(value),
          );
        });
  }

  Widget phoneInputField(BuildContext context, bool isEnabled) {
    return BlocBuilder<ContactCubit, ContactState>(
        buildWhen: (previous, current) =>
            previous.phoneField != current.phoneField,
        builder: (context, state) {
          final t = AppLocalizations.of(context)!;
          return TextInput(
            key: const Key('phone'),
            hint: t.phone,
            keyboardType: TextInputType.phone,
            initialValue: state.phoneField.value,
            hasError: state.phoneField.hasError,
            error: t.enterValidPhone,
            enabled: isEnabled,
            onChanged: (value) =>
                context.read<ContactCubit>().phoneChanged(value),
          );
        });
  }

  Widget roleInputField(BuildContext context, bool isEnabled) {
    return BlocBuilder<ContactCubit, ContactState>(
        buildWhen: (previous, current) =>
            previous.roleField != current.roleField,
        builder: (context, state) {
          final t = AppLocalizations.of(context)!;
          return TextInput(
            key: const Key('role'),
            hint: t.role,
            keyboardType: TextInputType.name,
            initialValue: state.roleField.value,
            hasError: state.roleField.hasError,
            error: t.enterValidRole,
            enabled: isEnabled,
            onChanged: (value) =>
                context.read<ContactCubit>().roleChanged(value),
          );
        });
  }

  Widget saveButton(bool isEnabled) {
    return BlocBuilder<ContactCubit, ContactState>(
        buildWhen: (previous, current) =>
            previous.isValid != current.isValid ||
            previous.status != current.status,
        builder: (context, state) {
          logger.i(
              'ContactPage -> status:${state.isValid} first:${state.firstNameField.isValid} last:${state.lastNameField.isValid} email:${state.emailField.isValid} phone:${state.phoneField.isValid} role:${state.roleField.isValid}');
          return Padding(
            padding: const EdgeInsets.only(top: 15),
            child: ElevatedButton(
                key: const Key('save'),
                onPressed:
                    (state.isValid && !state.status.inProgress) && isEnabled
                        ? () async =>
                            await context.read<ContactCubit>().saveContact()
                        : null,
                child: Text(AppLocalizations.of(context)!.save)),
          );
        });
  }

  Widget deleteButton(bool isEnabled) {
    return BlocBuilder<ContactCubit, ContactState>(builder: (context, state) {
      return state.isNew
          ? Container()
          : Padding(
              padding: const EdgeInsets.only(top: 15),
              child: ElevatedButton(
                  key: const Key('delete'),
                  onPressed: state.status.inProgress || !isEnabled
                      ? null
                      : () async => await _deleteContact(context),
                  child: Text(AppLocalizations.of(context)!.delete)),
            );
    });
  }

  Future<void> _deleteContact(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    var cancelButton = TextButton(
      child: Text(t.cancel),
      onPressed: () => Navigator.of(context).pop(), // dismiss dialog,
    );
    var okButton = TextButton(
      child: Text(t.ok),
      onPressed: () async {
        Navigator.of(context).pop(); // dismiss dialog
        await context.read<ContactCubit>().deleteContact();
      },
    );
    // set up the AlertDialog
    var confirm = AlertDialog(
      title: Text(t.delete),
      content: Text(t.deleteThisContact),
      actions: [
        cancelButton,
        okButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return confirm;
      },
    );
  }
}
