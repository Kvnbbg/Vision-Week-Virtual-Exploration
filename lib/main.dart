import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Import the navigation screen

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
      // Local database login logic (assuming `database` is defined elsewhere)
      if (database != null) {
        try {
          final List<Map<String, dynamic>> users = await database!.query(
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
            children: [
              // Username input field
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              // Password input field
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              // Login button
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
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