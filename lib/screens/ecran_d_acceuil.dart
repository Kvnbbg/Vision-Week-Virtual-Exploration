import 'package:flutter/material.dart';

class EcranDAccueil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Failed'),
      ),
      body: Center(
        child: Text(
          'Incorrect email or password. Please try again.',
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      ),
    );
  }
}
