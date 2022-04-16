import 'package:directory/models/contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContactsEditButton extends StatelessWidget {
  const ContactsEditButton({
    Key? key,
    required this.contact,
    required this.onEdit,
    required this.color,
  }) : super(key: key);

  final Contact contact;
  final Function(BuildContext context, Contact contact) onEdit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('edit'),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onPressed: () => onEdit(context, contact),
      icon: Icon(
        Icons.edit,
        color: color,
      ),
      tooltip: AppLocalizations.of(context)!.edit,
    );
  }
}
