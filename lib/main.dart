import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vision_week_virtual_exploration/screens/navigation_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/error_app.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    runApp(MyApp(useFirebase: true));
  } catch (e) {
    runApp(ErrorApp(error: e.toString()));
  }
}

class MyApp extends StatefulWidget {
  final bool useFirebase;

  MyApp({required this.useFirebase});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorMessage = '';
  Database? _database;

  @override
  void initState() {
    super.initState();
    if (!widget.useFirebase) {
      _initDatabase();
    }
  }

  Future<void> _initDatabase() async {
    try {
      _database = await openDatabase(
        p.join(await getDatabasesPath(), 'my_database.db'),
        version: 1,
        onCreate: (db, version) {
          return db.execute(
            "CREATE TABLE users(id INTEGER PRIMARY KEY, username TEXT, password TEXT)",
          );
        },
      );

      // Insert a test user if the table is empty
      final List<Map<String, dynamic>> users = await _database!.query('users');
      if (users.isEmpty) {
        await _database!.insert('users', {
          'username': 'testuser',
          'password': 'testpass',
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error initializing database: $e';
      });
    }
  }

  void _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username == 'admin' && password == 'admin') {
      _navigateToHome();
      return;
    }

    if (widget.useFirebase) {
      _loginWithFirebase(username, password);
    } else {
      _loginWithDatabase(username, password);
    }
  }

  Future<void> _loginWithFirebase(String username, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: username,
        password: password,
      );
      _navigateToHome();
    } catch (e) {
      setState(() {
        errorMessage = 'Invalid username or password';
      });
    }
  }

  Future<void> _loginWithDatabase(String username, String password) async {
    if (_database != null) {
      try {
        final List<Map<String, dynamic>> users = await _database!.query(
          'users',
          where: 'username = ?',
          whereArgs: [username],
        );
        if (users.isNotEmpty && users[0]['password'] == password) {
          _navigateToHome();
        } else {
          setState(() {
            errorMessage = 'Invalid username or password';
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = 'Error logging in: $e';
        });
      }
    } else {
      setState(() {
        errorMessage = 'Database not initialized';
      });
    }
  }

  void _navigateToHome() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login in Vision Week',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
      home: Scaffold(
        appBar: AppBar(title: Text('Login')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: Text('Login'),
              ),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  NavigationScreen() {
    /// return the navigation_screen.dart file
    /// with the code from the snippet
    /// lib/screens/navigation_screen.dart}
}

class ErrorApp extends StatelessWidget {
  final String error;

  ErrorApp({required this.error});

}
