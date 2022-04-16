import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactButton extends StatelessWidget {
  const ContactButton({
    Key? key,
    required this.icon,
    required this.scheme,
    required this.path,
    required this.tooltip,
  }) : super(key: key);

  final IconData icon;
  final String scheme;
  final String path;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final launchUri = Uri(
      scheme: scheme,
      path: path,
    ).toString();
    return FutureBuilder<bool>(
        future: canLaunch(launchUri),
        builder: (context, snapshot) {
          return IconButton(
              tooltip: tooltip,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(icon, size: 24),
              onPressed: (snapshot.hasData && (snapshot.data ?? false))
                  ? () async {
                      await launch(launchUri);
                    }
                  : null);
        });
  }
}
