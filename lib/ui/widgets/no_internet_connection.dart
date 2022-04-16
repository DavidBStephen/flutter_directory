import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NoInternetConnection extends StatelessWidget {
  const NoInternetConnection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Text(
        AppLocalizations.of(context)!.noInternetConnection,
        style: const TextStyle(color: Colors.red),
      );
}
