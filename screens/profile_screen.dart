import 'package:flutter/material.dart';

class EcranProfil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
            CircleAvatar(
            radius: 50.0,
            backgroundImage: AssetImage('assets/images/profile_image.jpg'),
          ),
          SizedBox(height: 16.0),
          Text(
            'Hélène Hills',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Text(
            'Développeur',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0, color: Colors.grey)
          ),
          SizedBox(height: 8),
          Text('@nomutilisateur'),
          SizedBox(height: 8),
          Text('nom@domaine.com'),
          SizedBox(height: 8),
          Text('siteweb.net\nmonlien.net\nvotrelien.net'),
          SizedBox(height: 8),
          Text('Une description de cet utilisateur.'),
            SizedBox(height: 8),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                    Icon(Icons.phone),
                    Icon(Icons.email),
                    Icon(Icons.web),
                ],
                ),
        ],
        ),
    );
  }
}