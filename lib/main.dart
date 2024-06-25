import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(SemaineVisionApp());
}

class SemaineVisionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vision Week',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics()),
      ],
      home: EcranPrincipal(),
    );
  }
}

class EcranPrincipal extends StatefulWidget {
  @override
  _EcranPrincipalState createState() => _EcranPrincipalState();
}

class _EcranPrincipalState extends State<EcranPrincipal> {
  int _selectedIndex = 0;
  final FirebaseAnalytics _analytics = FirebaseAnalytics();

  static const List<Widget> _widgetOptions = <Widget>[
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
    _analytics.logEvent(name: 'changement_onglet', parameters: {'index': index});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Semaine Vision'),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
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

// Placeholder widget classes (Replace with actual widget implementations)
class EcranAccueil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Accueil'));
  }
}

class EcranProfil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Profil'));
  }
}

class EcranCarte extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Carte'));
  }
}

class EcranVideo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Vidéos'));
  }
}

class EcranVR extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('VR'));
  }
}

class EcranParametres extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Paramètres'));
  }
}
