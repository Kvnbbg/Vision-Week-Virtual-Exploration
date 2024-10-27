import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../auth/auth_service.dart';
import '../settings/theme_provider.dart';
import 'login.dart'; // Import your login screen if needed

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _generatedText = "Press the button to generate text!";
  final List<String> _animalImages = [
    'assets/images/lion.jpg',
    'assets/images/tiger.jpg',
    'assets/images/elephant.jpg',
    'assets/images/giraffe.jpg',
    'assets/images/zebra.jpg',
  ];
  
  final List<String> _animalNames = [
    'Lion',
    'Tiger',
    'Elephant',
    'Giraffe',
    'Zebra',
  ];

  String _feedback = '';
  final List<String> _feedbackList = [];

  void _generateRandomText() {
    const texts = [
      "Welcome to Vision Week!",
      "Explore and discover new possibilities!",
      "Let's make the most out of our virtual journey!",
      "Embrace creativity and innovation!",
      "Join us in our exploration adventures!",
    ];

    setState(() {
      _generatedText = texts[Random().nextInt(texts.length)];
    });
  }

  void _logout() async {
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  void _submitFeedback() {
    if (_feedback.isNotEmpty) {
      setState(() {
        _feedbackList.add(_feedback);
        _feedback = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.homeTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
          Switch(
            value: Provider.of<SettingsProvider>(context).themeMode == ThemeMode.dark,
            onChanged: (value) {
              Provider.of<SettingsProvider>(context, listen: false).toggleTheme(value);
            },
          ),
          DropdownButton<String>(
            value: Provider.of<SettingsProvider>(context).locale.languageCode,
            onChanged: (String? newValue) {
              if (newValue != null) {
                Provider.of<SettingsProvider>(context, listen: false).switchLocale(newValue);
              }
            },
            items: <String>['en', 'fr'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.toUpperCase()),
              );
            }).toList(),
            icon: Icon(Icons.language),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          appLocalizations.welcomeMessage,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Text(
                          appLocalizations.exploreZoo,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to the zoo exploration page
                          },
                          child: Text(appLocalizations.startExploring),
                        ),
                        SizedBox(height: 20),
                        Text(
                          _generatedText,
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _generateRandomText,
                          child: Text(appLocalizations.generateText),
                        ),
                        SizedBox(height: 20),
                        // Animal Gallery
                        Text(
                          appLocalizations.animalGallery,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                          ),
                          itemCount: _animalImages.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: Column(
                                children: [
                                  Image.asset(_animalImages[index], fit: BoxFit.cover),
                                  Text(_animalNames[index]),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        // Feedback Section
                        Text(
                          appLocalizations.feedbackTitle,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        TextField(
                          decoration: InputDecoration(
                            labelText: appLocalizations.feedbackLabel,
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _feedback = value;
                            });
                          },
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _submitFeedback,
                          child: Text(appLocalizations.submitFeedback),
                        ),
                        SizedBox(height: 20),
                        // Display Feedback
                        Text(
                          appLocalizations.feedbackListTitle,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        ..._feedbackList.map((feedback) => ListTile(title: Text(feedback))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
