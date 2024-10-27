import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../lib/auth/auth_service.dart';
import '../lib/settings/theme_provider.dart';

class EcranPrincipal extends StatefulWidget {
  @override
  _EcranPrincipalState createState() => _EcranPrincipalState();
}

class _EcranPrincipalState extends State<EcranPrincipal> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    Text('Welcome to the Vision Week Virtual Exploration!'),
    ProfileScreen(),
    MapScreen(),
    ExploreScreen(),
    FavoritesScreen(),
    SettingsScreen(),
    VRTourScreen(),
    AboutScreen(),
    ContactScreen(),
    HelpScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = Provider.of<AuthService>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: Text('${appLocalizations!.welcomeTitle} ${user?.email}'),
        actions: [
          Switch(
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
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
            icon: Icon(Icons.explore),
            label: appLocalizations.exploreZoo,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: appLocalizations.videos,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: appLocalizations.settings,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.vrpano),
            label: appLocalizations.vrViewer,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: appLocalizations.settingsScreen,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_mail),
            label: appLocalizations.userProfile,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help),
            label: appLocalizations.interactiveMap,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Mock screens for demonstration purposes
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Profile'));
  }
}

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Map'));
  }
}

class ExploreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Explore'));
  }
}

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Favorites'));
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Settings'));
  }
}

class VRTourScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('VR Tour'));
  }
}

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('About'));
  }
}

class ContactScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Contact'));
  }
}

class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Help'));
  }
}
