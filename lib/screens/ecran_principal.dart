import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';

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
    final user = Provider.of<AuthService>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${user?.email}'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.vrpano),
            label: 'VR Tour',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_mail),
            label: 'Contact',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help),
            label: 'Help',
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
