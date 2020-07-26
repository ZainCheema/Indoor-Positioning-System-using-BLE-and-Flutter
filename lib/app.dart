import 'package:flutter/material.dart';
import 'package:umbrella/View/NearbyScreen.dart';
import 'package:umbrella/View/OpeningScreen.dart';

import 'Model/AppStateModel.dart';




class UmbrellaMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Umbrella', home: BottomNav());
  }
}

class BottomNav extends StatefulWidget {
  @override
  BottomNavState createState() {
    return BottomNavState();
  }
}

class BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    OpeningScreen(),
    NearbyScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    AppStateModel appStateModel = AppStateModel.instance;
    
    appStateModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.record_voice_over),
              title: Text('Anchor'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_walk),
              title: Text('Mobile'),
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          onTap: _onItemTapped,
        ));
  }
}