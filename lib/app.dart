import 'package:flutter/material.dart';
import 'package:umbrella/View/FeedScreen.dart';
import 'package:umbrella/View/NearbyScreen.dart';
import 'package:umbrella/styles.dart';
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
    FeedScreen(),
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
        appBar: new AppBar(
          backgroundColor: createMaterialColor(Color(0xFFE8E6D9)),
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Umbrella',
                style: TextStyle(color: Colors.black),
              ),
              const Image(image: AssetImage('assets/icons8-umbrella-24.png'))
            ],
          ),
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('Feed'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              title: Text('Nearby'),
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          onTap: _onItemTapped,
        ));
  }
}
