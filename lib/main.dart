// main.dart
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login/Register',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginRegisterScreen(),
    );
  }
}

class LoginRegisterScreen extends StatefulWidget {
  @override
  _LoginRegisterScreenState createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  bool showLogin = true;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  String loginUsername = '';
  String loginPassword = '';
  String registerUsername = '';
  String registerPassword = '';
  String loginError = '';
  String registerError = '';

  void toggleForm() {
    setState(() {
      showLogin = !showLogin;
      loginError = '';
      registerError = '';
    });
  }

  void login() {
    if (_loginFormKey.currentState!.validate()) {
      if (loginUsername == 'admin' && loginPassword == 'admin') {
        // Successful login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful!')),
        );
      } else {
        setState(() {
          loginError = 'Invalid username or password';
        });
      }
    }
  }

  void register() {
    if (_registerFormKey.currentState!.validate()) {
      // Registration logic
      setState(() {
        registerError = 'Registration not implemented';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome!'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showLogin) ...[
                Text('Login', style: TextStyle(fontSize: 24)),
                Form(
                  key: _loginFormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Username'),
                        onChanged: (value) {
                          loginUsername = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        onChanged: (value) {
                          loginPassword = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      if (loginError.isNotEmpty)
                        Text(loginError, style: TextStyle(color: Colors.red)),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: login,
                        child: Text('Login'),
                      ),
                      TextButton(
                        onPressed: toggleForm,
                        child: Text('Don\'t have an account? Register'),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text('Register', style: TextStyle(fontSize: 24)),
                Form(
                  key: _registerFormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Username'),
                        onChanged: (value) {
                          registerUsername = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        onChanged: (value) {
                          registerPassword = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      if (registerError.isNotEmpty)
                        Text(registerError, style: TextStyle(color: Colors.red)),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: register,
                        child: Text('Register'),
                      ),
                      TextButton(
                        onPressed: toggleForm,
                        child: Text('Already have an account? Login'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}