import 'package:directory/models/contact.dart';
import 'package:flutter/material.dart';

import 'contact_button.dart';
import 'contacts_edit_button.dart';

class ContactsCard extends StatelessWidget {
  const ContactsCard({
    Key? key,
    required this.contact,
    required this.onEdit,
  }) : super(key: key);

  final Contact contact;
  final Function(BuildContext context, Contact contact) onEdit;

  @override
  Widget build(BuildContext context) {
    final titleColor =
        Theme.of(context).textTheme.titleMedium?.color ?? Colors.grey;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(contact.initials),
          radius: 25,
        ),
        title: Text('${contact.firstName} ${contact.lastName}'),
        isThreeLine: false,
        subtitle: Column(
          children: [
            Row(children: [
              ContactButton(
                  icon: Icons.phone,
                  scheme: 'tel',
                  path: contact.phone,
                  tooltip: 'call'),
              ContactButton(
                  icon: Icons.sms,
                  scheme: 'sms',
                  path: contact.phone,
                  tooltip: 'text'),
              const SizedBox(width: 12),
              Text(contact.phone),
            ]),
            Row(
              children: [
                ContactButton(
                    icon: Icons.email,
                    scheme: 'mailto',
                    path: contact.email,
                    tooltip: 'email'),
                const SizedBox(width: 12),
                Text(contact.email),
              ],
            ),
          ],
        ),
        trailing: ContactsEditButton(
            contact: contact, onEdit: onEdit, color: titleColor),
      ),
    );
  }
}
