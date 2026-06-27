import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'feedback_screen.dart';
import 'login_screen.dart';

Widget buildAppDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: const Text(
            'Menu',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Paramètres'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Paramètres à venir')),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.feedback),
          title: const Text('Feedback'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackScreen()));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Feedback à venir')),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.login),
          title: const Text('Connexion'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Connexion à venir')),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('À propos'),
          onTap: () {
            Navigator.pop(context);
            showAboutDialog(
              context: context,
              applicationName: 'TSL Traducteur',
              applicationVersion: '1.0',
              applicationIcon: Icon(Icons.translate),
              children: [
                Text('Cette application traduit la langue des signes tunisienne en texte et parole.'),
              ],
            );
          },
        ),
      ],
    ),
  );
}
