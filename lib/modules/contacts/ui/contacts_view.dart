import 'package:directory/models/contact.dart';
import 'package:flutter/material.dart';
import '../../../models/contacts.dart';
import 'contacts_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContactsView extends StatefulWidget {
  const ContactsView({Key? key, required this.contacts, required this.onEdit})
      : super(key: key);
  final Contacts contacts;
  final Function(BuildContext context, Contact contact) onEdit;

  @override
  State<StatefulWidget> createState() => _ContactsViewState();
}

class _ContactsViewState extends State<ContactsView> {
  late String _filterText;

  @override
  void initState() {
    _filterText = '';
    super.initState();
  }

  void _setFilter(String value) => setState(() => _filterText = value);

  @override
  Widget build(BuildContext context) {
    final hasLoaded = widget.contacts.records.isNotEmpty;
    final records = widget.contacts.records
        .where((contact) => contact.contains(_filterText))
        .toList();
    final t = AppLocalizations.of(context)!;
    final titleColor =
        Theme.of(context).textTheme.titleMedium?.color ?? Colors.grey;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            autofocus: false,
            onChanged: (value) => _setFilter(value),
            decoration: InputDecoration(
                labelText: t.search,
                focusColor: titleColor,
                suffixIcon: Icon(
                  Icons.search,
                  color: titleColor,
                )),
          ),
        ),
        Expanded(
          child: records.isNotEmpty || !hasLoaded
              ? ListView.builder(
                  itemBuilder: (context, index) {
                    return ContactsCard(
                        contact: records[index], onEdit: widget.onEdit);
                  },
                  itemCount: records.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(5),
                  scrollDirection: Axis.vertical,
                )
              : Text(
                  t.noResultsFound,
                  style: const TextStyle(fontSize: 24),
                ),
        ),
      ],
    );
  }
}
