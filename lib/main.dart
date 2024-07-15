import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'navigation_screen.dart';

// Define the NavigationScreen class (if not defined in a separate file)
class NavigationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navigation Screen'),
      ),
      body: Center(
        child: Text('Welcome to the Navigation Screen!'),
      ),
    );
  }
}

// Main application widget
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

  // Initialize the local database
  Future<void> _initDatabase() async {
    _database = await openDatabase(
      p.join(await getDatabasesPath(), 'my_database.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE users(id INTEGER PRIMARY KEY, username TEXT, password TEXT)",
        );
      },
    );

    // Insert a test user
    await _database!.insert('users', {
      'username': 'testuser',
      'password': 'testpass',
    });
  }

  // Method to handle login logic
  void _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    // Special case for admin login
    if (username == 'admin' && password == 'admin') {
      // Directly navigate to the navigation screen for admin
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NavigationScreen()),
      );
      return;
    }

    // Check if Firebase authentication is enabled
    if (widget.useFirebase) {
      // Firebase login logic
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: username,
          password: password,
        );
        // Navigate to the navigation screen upon successful login
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NavigationScreen()),
        );
      } catch (e) {
        // Display error message if login fails
        setState(() {
          errorMessage = 'Invalid username or password';
        });
      }
    } else {
      // Local database login logic
      if (_database != null) {
        try {
          final List<Map<String, dynamic>> users = await _database!.query(
            'users',
            where: 'username = ?',
            whereArgs: [username],
          );
          if (users.isNotEmpty && users[0]['password'] == password) {
            // Navigate to the navigation screen upon successful login
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NavigationScreen()),
            );
          } else {
            // Display error message if login fails
            setState(() {
              errorMessage = 'Invalid username or password';
            });
          }
        } catch (e) {
          // Display error message if there is an error querying the database
          setState(() {
            errorMessage = 'Error logging in';
          });
        }
      } else {
        // Display error message if the database is not initialized
        setState(() {
          errorMessage = 'Database not initialized';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Login')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Username input field
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              // Password input field
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              // Login button
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
              ),
              SizedBox(height: 10),
              // Display error message if any
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
}

// Entry point of the application
void main() => runApp(MyApp(useFirebase: false));
