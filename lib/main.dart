import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect

  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void startBeaconBroadcast() async {
    BeaconBroadcast beaconBroadcast = BeaconBroadcast();

    var transmissionSupportStatus =
        await beaconBroadcast.checkTransmissionSupported();
    switch (transmissionSupportStatus) {
      case BeaconStatus.SUPPORTED:
        print("You're good to go, you can advertise as a beacon");

    if(utf8.encode('3ce2ef69-4414-469d-9d55-3ec7fcc38520').length == 16) {
      print("UUID is valid.");
    } else {
      print(utf8.encode('3ce2ef69-4414-469d-9d55-3ec7fcc38520').length);
    }

    beaconBroadcast
        .setUUID('8b0ca750-e7a7-4e14-bd99-095477cb3e77')
        .setMajorId(1)
        .setMinorId(100)
        .setTransmissionPower(-59) //optional
        .setLayout(
            BeaconBroadcast.EDDYSTONE_UID_LAYOUT) //Android-only, optional
        .start();

    var ad = beaconBroadcast.isAdvertising();

    if (ad != null) {
      print("Beacon is advertising");
    }
        break;
      case BeaconStatus.NOT_SUPPORTED_MIN_SDK:
        // Your Android system version is too low (min. is 21)
        break;
      case BeaconStatus.NOT_SUPPORTED_BLE:
        // Your device doesn't support BLE
        break;
      case BeaconStatus.NOT_SUPPORTED_CANNOT_GET_ADVERTISER:
        // Either your chipset or driver is incompatible
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    
    startBeaconBroadcast();


    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
