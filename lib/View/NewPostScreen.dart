import 'package:flutter/material.dart';
import 'package:umbrella/widgets.dart';

class NewPostScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: buildThemeData(),
      home: new Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
              Navigator.pop(context);
          }),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('New Post'),
              const Image(image: AssetImage('assets/icons8-post-box-24.png'))
            ],
          ),
      )
      )
    );
  }
}