import 'package:flutter/material.dart';
import 'package:vision_week_virtual_exploration/l10n/l10n.dart';

class EcranAccueil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            appLocalizations.welcomeMessage,
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 20),
          Text(
            appLocalizations.exploreZoo,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
