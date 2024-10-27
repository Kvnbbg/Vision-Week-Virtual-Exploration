import 'package:flutter/material.dart';

class EcranVR extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Réalité Virtuelle\nPlongez dans le monde du zoo en réalité virtuelle !',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24.0),
      ),
    );
  }
}