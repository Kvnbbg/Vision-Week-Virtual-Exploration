import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  // Ensure that widget binding is initialized before any other operations
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    
    // Configure Firestore settings
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    
    // Run the main application
    runApp(SemaineVisionApp());
  } catch (e) {
    // If Firebase initialization fails, run the error application
    runApp(ErrorApp(error: e.toString()));
  }
}

// Main application widget
class SemaineVisionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vision Week',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: [
        // Add Firebase Analytics observer
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
      home: WelcomeScreen(), // Set the initial screen to WelcomeScreen
    );
  }
}

// Error application widget to display initialization errors
class ErrorApp extends StatelessWidget {
  final String error;

  ErrorApp({required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(child: Text('Failed to initialize Firebase: $error')),
      ),
    );
  }
}

// Main screen with bottom navigation
class EcranPrincipal extends StatefulWidget {
  @override
  _EcranPrincipalState createState() => _EcranPrincipalState();
}

class _EcranPrincipalState extends State<EcranPrincipal> {
  int _selectedIndex = 0; // Index of the currently selected tab
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // List of widgets for each tab
  static final List<Widget> _widgetOptions = <Widget>[
    EcranAccueil(),
    EcranProfil(),
    EcranCarte(),
    EcranVideo(),
    EcranVR(),
    EcranParametres(),
  ];

  // Handle tab selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Log tab change event to Firebase Analytics
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
        child: _widgetOptions[_selectedIndex], // Display the selected tab's widget
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
        currentIndex: _selectedIndex, // Highlight the selected tab
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped, // Handle tab selection
      ),
    );
  }
}

// Widget for the 'Accueil' tab
class EcranAccueil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Accueil'));
  }
}

// Widget for the 'Profil' tab
class EcranProfil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Profil'));
  }
}

// Widget for the 'Carte' tab
class EcranCarte extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Carte'));
  }
}

// Widget for the 'Vidéos' tab
class EcranVideo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Vidéos'));
  }
}

// Widget for the 'VR' tab
class EcranVR extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('VR'));
  }
}

// Widget for the 'Paramètres' tab
class EcranParametres extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Paramètres'));
  }
}

// Welcome screen widget
class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Semaine Vision'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenue à la Semaine Vision !',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the main screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => EcranPrincipal()),
                );
              },
              child: Text('Commencer'),
            ),
          ],
        ),
      ),
    );
  }
}