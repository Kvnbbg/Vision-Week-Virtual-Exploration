import 'package:flutter/material.dart';

class EcranAccueil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Bienvenue à la Semaine Vision !',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 20),
          Text(
            'Explorez le zoo et découvrez nos animaux !',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
