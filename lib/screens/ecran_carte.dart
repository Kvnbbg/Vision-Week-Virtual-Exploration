import 'package:flutter/material.dart';

class EcranCarte extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Carte Interactive',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 20),
          Text(
            'Trouvez votre chemin dans le zoo avec notre carte interactive.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
