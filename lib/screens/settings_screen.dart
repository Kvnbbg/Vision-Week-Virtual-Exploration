import 'package:flutter/material.dart';

// A StatelessWidget representing the settings screen
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres'), // Screen title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Adds padding around the content
        child: Center(
          child: Text(
            'Paramètres',
            semanticsLabel: 'Settings Screen', // For better accessibility
            style: Theme.of(context).textTheme.titleLarge, // Use the app's theme
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      title: 'App de Paramètres', // Title for the app
      theme: ThemeData(
        primarySwatch: Colors.blue, // Define a primary theme color
      ),
      home: SettingsScreen(), // Main widget to show on the app start
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate, // To support multiple languages
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('fr', ''), // French localization
        const Locale('en', ''), // English localization
      ],
    ),
  );
}
