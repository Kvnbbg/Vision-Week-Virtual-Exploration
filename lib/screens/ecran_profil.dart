import 'package:flutter/material.dart';

class EcranProfil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Profil Utilisateur',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 20),
          Text(
            'Gérez votre profil et vos abonnements.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
