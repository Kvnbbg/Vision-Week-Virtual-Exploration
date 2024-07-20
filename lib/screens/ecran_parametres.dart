import 'package:flutter/material.dart';

class EcranParametres extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Paramètres',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 20),
          Text(
            'Ajustez vos paramètres de l\'application.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
