import 'package:flutter/material.dart';

class EcranProfil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            appLocalizations.userProfile,
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 20),
          Text(
            appLocalizations.manageProfile,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
