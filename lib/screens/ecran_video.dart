import 'package:flutter/material.dart';

class EcranVideo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Vidéos',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 20),
          Text(
            'Regardez des vidéos sur nos animaux et leurs habitats.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
