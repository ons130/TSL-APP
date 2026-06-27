import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Langue'),
            subtitle: Text('Français / Arabe / Anglais'),
          ),
          ListTile(
            leading: Icon(Icons.palette),
            title: Text('Thème'),
            subtitle: Text('Système / Clair / Sombre'),
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            subtitle: Text('Activées'),
          ),
        ],
      ),
    );
  }
}
