import 'package:directory/config/dependencies.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/logging.dart';
import '../../config/themes/bloc/theme_cubit.dart';
import '../../core/auth/bloc/auth_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/preference_service.dart';

class MainAppBar extends AppBar {
  MainAppBar({
    Key? key,
    required BuildContext context,
  }) : super(
          key: key,
          title: Text(AppLocalizations.of(context)!.appTitle),
          actions: createActions(context),
        );

  static List<Widget> createActions(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.titleMedium?.color ?? Colors.grey;
    return [
      PopupMenuButton(
          key: const Key('menu'),
          offset: const Offset(0, 60),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
          ),
          icon: const Icon(Icons.more_vert),
          itemBuilder: (_) => [
                PopupMenuItem<String>(
                  value: 'theme',
                  child: Row(
                    children: [
                      Icon(Icons.brightness_medium, color: textColor),
                      const SizedBox(width: 20),
                      Text(AppLocalizations.of(context)!.theme),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  key: const Key('exit'),
                  value: 'exit',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, color: textColor),
                      const SizedBox(width: 20),
                      Text(AppLocalizations.of(context)!.exit),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'about',
                  child: Row(
                    children: [
                      Icon(Icons.help, color: textColor),
                      const SizedBox(width: 20),
                      Text(AppLocalizations.of(context)!.about),
                    ],
                  ),
                ),
              ],
          onSelected: (index) async {
            switch (index) {
              case 'theme':
                await _toggleTheme(context);
                break;
              case 'exit':
                _exit(context);
                break;
              case 'about':
                await _showAbout(context);
                break;
            }
          })
    ];
  }

  static void _exit(BuildContext context) {
    context.read<AuthCubit>().signOut();
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    }
  }

  static Future<void> _toggleTheme(BuildContext context) async =>
      await context.read<ThemeCubit>().toggleTheme();

  static Future<void> _showAbout(BuildContext context) async {
    await FirebaseAnalytics.instance.logScreenView(screenName: 'about');
    await showDialog(
        context: context,
        builder: (context) {
          final t = AppLocalizations.of(context)!;
          return GestureDetector(
            onDoubleTap: () {
              final preferenceService = locator.get<PreferenceService>();
              preferenceService.skipIntroduction = false;
              logger.i('skipIntroduction reset');
            },
            child: AlertDialog(
              title: Text(t.aboutTitle),
              content: Text(t.aboutContent),
              actions: <Widget>[
                ElevatedButton(
                    child: Text(t.ok),
                    onPressed: () => Navigator.of(context).pop()),
              ],
            ),
          );
        });
  }
}
