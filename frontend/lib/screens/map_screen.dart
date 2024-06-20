import 'package: flutter/material.dart';

class EcranCarte extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Center(
        child: Text(
            'Carte Interractive\nCliquez sur les animaux pour en savoir plus ! Et trouvez votre chemin dans le zoo avec notre carte interactive !',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24.0),
        ),
        );
    }
    }