import 'package:flutter/material.dart';

class EcranVideo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Vidéos\nRegardez nos vidéos d\'animaux et leur habitats, ainsi vous pourrez en apprendre plus sur le zoo !',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24.0),
      ),
    );
  }
}
