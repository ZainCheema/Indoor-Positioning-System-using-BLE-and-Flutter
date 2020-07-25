import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:umbrella/View/NearbyScreen.dart';
import '../styles.dart';


// openScreen() {
//                 Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => NearbyScreen()),
//               );
// }



class OpeningScreen extends StatefulWidget {
  @override
  OpeningScreenState createState() {
    return OpeningScreenState();
  }
}

class OpeningScreenState extends State<OpeningScreen> {
  @override
  void initState() {
    super.initState();
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
      body: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Center(child: FloatingActionButton(
              onPressed: null, 
              child: Text("START"))),
          ]),
    );
  }
}
