import 'package:directory/constants/status.dart';
import 'package:directory/core/auth/bloc/auth_cubit.dart';
import 'package:directory/core/connectivity/bloc/connectivity_cubit.dart';
import 'package:directory/models/contact.dart';
import 'package:directory/modules/contact/ui/contact_page.dart';
import 'package:directory/modules/contacts/bloc/contacts_cubit.dart';
import 'package:directory/ui/widgets/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'contacts_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  State<ContactsPage> createState() => _ContactsPageState();

  static Route<Contact> _buildRoute(BuildContext context, Object? params) {
    final map = params as Map<Object?, Object?>;
    final contact = Contact.fromJson(
        map['id'] as String, map['contact'] as Map<Object?, Object?>);
    final isNew = map['isNew'] as bool;
    return MaterialPageRoute<Contact>(
      builder: (BuildContext context) =>
        BlocProvider<AuthCubit>(
          lazy: false,
          create: (_) => AuthCubit(),
          child: ContactPage(contact: contact, isNew: isNew),
        ),
    );
  }
}

class _ContactsPageState extends State<ContactsPage> with RestorationMixin {
  late RestorableRouteFuture<Contact?> _contactRoute;

  final _contactsCubit = ContactsCubit();

  @override
  void initState() {
    super.initState();
    _contactRoute = RestorableRouteFuture<Contact?>(
        onPresent: (NavigatorState navigator, Object? arguments) {
      return Navigator.restorablePush(context, ContactsPage._buildRoute,
          arguments: arguments);
    }, onComplete: (Contact? contact) {
      // Reload contacts as they have been updated, added or deleted
      final isSignedIn = context.read<AuthCubit>().isSignedIn;
      final isConnected = context.read<ConnectivityCubit>().isConnected;
      if (isSignedIn && isConnected) {
        _contactsCubit.getContacts(isConnected: true, refresh: true);
      }
    });
  }

  Future<void> _newContact(BuildContext context) async {
    await _editContactDetails(context, const Contact(), true);
  }

  Future<void> _editContact(BuildContext context, Contact contact) =>
      _editContactDetails(context, contact, false);

  Future<void> _editContactDetails(
      BuildContext context, Contact contact, bool isNew) async {
    final arguments = {
      'id': contact.id,
      'isNew': isNew,
      'contact': contact.toJson()
    };
    _contactRoute.present(arguments);
  }

  @override
  String? get restorationId => "contacts_screen";

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_contactRoute, "contacts_route");
  }

  @override
  void dispose() {
    super.dispose();
    _contactRoute.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
        builder: (context, connectivity) {
      return BlocProvider<ContactsCubit>(
        lazy: false,
        create: (BuildContext context) => _contactsCubit,
        child: FutureBuilder<void>(
            future: _contactsCubit.getContacts(
                isConnected: connectivity.isConnected),
            builder: (context, snapshot) {
              final initialLoad =
                  snapshot.connectionState != ConnectionState.done;
              return Scaffold(
                appBar: MainAppBar(context: context),
                body: BlocBuilder<ContactsCubit, ContactsState>(
                  builder: (context, state) => LoadingOverlay(
                    child: ContactsView(
                      contacts: state.contacts,
                      onEdit: _editContact,
                    ),
                    isLoading: state.status.inProgress || initialLoad,
                  ),
                ),
                floatingActionButton: BlocBuilder<ContactsCubit, ContactsState>(
                  builder: (context, state) => Visibility(
                    visible:
                        !state.status.inProgress && connectivity.isConnected,
                    child: FloatingActionButton(
                      key: const Key('newcontact'),
                      onPressed: () async => await _newContact(context),
                      child: const Icon(Icons.add),
                      mini: true,
                      tooltip: AppLocalizations.of(context)!.newContact,
                    ),
                  ),
                ),
              );
            }),
      );
    });
  }
}
