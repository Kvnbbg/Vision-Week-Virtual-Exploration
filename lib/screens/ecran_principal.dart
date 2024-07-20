import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:vision_week_virtual_exploration/screens/ecran_accueil.dart';
import 'package:vision_week_virtual_exploration/screens/ecran_profil.dart';
import 'package:vision_week_virtual_exploration/screens/ecran_carte.dart';
import 'package:vision_week_virtual_exploration/screens/ecran_video.dart';
import 'package:vision_week_virtual_exploration/screens/ecran_vr.dart';
import 'package:vision_week_virtual_exploration/screens/ecran_parametres.dart';
import 'package:vision_week_virtual_exploration/l10n/l10n.dart';

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
      _selectedIndex = index);
    });
    _analytics.logEvent();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.appTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => WelcomeScreen()),
              );
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _widgetOptions[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: appLocalizations.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: appLocalizations.profile,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: appLocalizations.map,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: appLocalizations.videos,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.vrpano),
            label: appLocalizations.vr,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: appLocalizations.settings,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
