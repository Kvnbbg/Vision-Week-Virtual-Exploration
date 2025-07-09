import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations
import 'ecran_principal.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!; // Get AppLocalizations instance

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.welcomeAppBarTitle), // Use localized string
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              appLocalizations.welcomeMessageBody, // Use localized string
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center, // Added for better centering of longer text
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => EcranPrincipal()),
                );
              },
              child: Text(appLocalizations.welcomeStartButton), // Use localized string
            ),
          ],
        ),
      ),
    );
  }
}
