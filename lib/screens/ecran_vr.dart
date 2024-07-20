import 'package:flutter/material.dart';

class EcranVR extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'VR Viewer',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 20),
          Text(
            'Découvrez le zoo en réalité virtuelle.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
