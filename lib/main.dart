/// The above code sets up a Flutter application with Firebase integration, including Firebase Analytics
/// and Cloud Firestore, to display different tabs for a Vision Week app.
import 'package:flutter/material.dart';
// Importing Firebase core package
import 'package:firebase_core/firebase_core.dart';

// Importing Firebase Analytics package
import 'package:firebase_analytics/firebase_analytics.dart';

// Importing Firebase Analytics observer package

// Importing Cloud Firestore package
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  // Ensuring Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initializing Firebase
  await Firebase.initializeApp();
  // Configuring Firestore settings
  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  // Running the main application
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
      // Adding Firebase Analytics observer
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
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
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // List of widget options for different tabs
  static List<Widget> _widgetOptions = <Widget>[
    EcranAccueil(),
    EcranProfil(),
    EcranCarte(),
    EcranVideo(),
    EcranVR(),
    EcranParametres(),
  ];

  // Handling tab selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Logging tab change event to Firebase Analytics
    _analytics.logEvent(name: 'changement_onglet', parameters: {'index': index});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Semaine Vision'),
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        // Displaying the selected widget
        child: _widgetOptions.elementAt(_selectedIndex),
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
        // Handling item tap
        onTap: _onItemTapped,
      ),
    );
  }
}

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
