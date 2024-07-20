import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:vision_week_virtual_exploration/screens/ecran_accueil.dart';
import 'package:vision_week_virtual_exploration/screens/ecran_profil.dart';
import 'package:vision_week_virtual_exploration/screens/ecran_carte.dart';
import 'package:vision_week_virtual_exploration/screens/ecran_video.dart';
import 'package:vision_week_virtual_exploration/screens/ecran_vr.dart';
import 'package:vision_week_virtual_exploration/screens/ecran_parametres.dart';

class EcranPrincipal extends StatefulWidget {
  @override
  _EcranPrincipalState createState() => _EcranPrincipalState();
}

class _EcranPrincipalState extends State<EcranPrincipal> {
  int _selectedIndex = 0;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static final List<Widget> _widgetOptions = <Widget>[
    EcranAccueil(),
    EcranProfil(),
    EcranCarte(),
    EcranVideo(),
    EcranVR(),
    EcranParametres(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _analytics.logEvent(name: 'tab_change', parameters: {'index': index});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vision Week'),
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _widgetOptions[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Carte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Vidéos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.vrpano),
            label: 'VR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
