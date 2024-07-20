import 'package:flutter/material.dart';

class EcranAccueil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil'),
      ),
      body: Center(
        child: Text('Bienvenue à l'écran d'accueil'),
      ),
    );
  }
}
