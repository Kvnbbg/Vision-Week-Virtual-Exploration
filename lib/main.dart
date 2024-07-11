import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'navigation.dart'; // Import the navigation screen

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

  void _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username == 'admin' && password == 'admin') {
      // Directly navigate to the navigation screen for admin
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NavigationScreen()),
      );
      return;
    }

    if (widget.useFirebase) {
      // Firebase login logic
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: username,
          password: password,
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NavigationScreen()),
        );
      } catch (e) {
        setState(() {
          errorMessage = 'Invalid username or password';
        });
      }
    } else {
      if (database != null) {
        try {
          final List<Map<String, dynamic>> users = await database!.query(
            'users',
            where: 'username = ?',
            whereArgs: [username],
          );
          if (users.isNotEmpty && users[0]['password'] == password) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NavigationScreen()),
            );
          } else {
            setState(() {
              errorMessage = 'Invalid username or password';
            });
          }
        } catch (e) {
          setState(() {
            errorMessage = 'Error logging in';
          });
        }
      } else {
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
}

void main() => runApp(MyApp(useFirebase: false));