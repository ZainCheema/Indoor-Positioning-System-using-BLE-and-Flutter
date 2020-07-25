import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'User.dart';
import 'package:random_words/random_words.dart';

class AppStateModel extends foundation.ChangeNotifier {
  // Singleton
  AppStateModel._();

  static AppStateModel _instance = new AppStateModel._();

  static AppStateModel get instance => _instance;

  bool wifiEnabled = false;
  bool gpsEnabled = false;
  bool bluetoothEnabled = false;

  PermissionStatus locationPermissionStatus = PermissionStatus.unknown;

  Uuid uuid = new Uuid();

  // User of the app.
  User user;

  // A list of all users in the app.
  List<User> allUsers;

  // All nearby users.
  List<User> nearbyUsers;

  CollectionReference userPath = Firestore.instance
      .collection('Country')
      .document('City')
      .collection('Street')
      .document('Users')
      .collection('User');

  Stream<QuerySnapshot> userSnapshots;

  // ignore: cancel_subscriptions
  StreamSubscription usersStream;

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  void init() async {
    // This will check wifi, gps and bluetooth
    // If all these checks pass, create the user, then load the nearby users
    debugPrint("init() called");

    allUsers = new List<User>();
    nearbyUsers = new List<User>();

    if (wifiEnabled & bluetoothEnabled & gpsEnabled) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      String userName = androidInfo.model.toString();
      print('Running on $userName');

      String userId = uuid.v1().toString();
      userId = userId.replaceAll(RegExp('-'), '');

      if (Platform.isAndroid) {
        // For Android, the user's uuid has to be 20 chars long to conform
        // with Eddystones NamespaceId length
        // Also has to be without hyphens
        userId = userId.substring(0, 20);

        if (userId.length == 20) {
          debugPrint("Android users ID is the correct format");
        } else {
          debugPrint('user ID was of an incorrect format');
          debugPrint(userId);
          debugPrint("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
        }
      }

      // FlutterCompass.events.listen((double direction) async {
      //  // String facing = angleToClockFace(direction.round());

      //   Map<String, dynamic> userJson = {
      //     'UUID': userId,
      //     'UserName': userName,
      //     'Facing': "",
      //     'Direction': 0
      //   };

      //   uploadUser(userJson);
      // });

      Map<String, dynamic> userJson = {
        'UUID': userId,
        'UserName': userName,
        'Facing': "",
        'Direction': 0
      };

      uploadUser(userJson);

      streamUsers();
    }
  }

  void uploadUser(Map<String, dynamic> json) async {
    user = new User.fromJson(json);

    await userPath.document(user.uuid).setData({
      'UUID': user.uuid,
      'UserName': user.userName,
      'Facing': user.facing,
      'Direction': user.direction
    });

    debugPrint("User uploaded!");
  }

  void streamUsers() {
    userSnapshots = Firestore.instance.collection(userPath.path).snapshots();

    usersStream = userSnapshots.listen((s) {
      //  debugPrint("USER ADDED");
      allUsers.clear();
      for (var document in s.documents) {
        allUsers = List.from(allUsers);
        allUsers.add(User.fromJson(document.data));
      }
      //     debugPrint("ALL USERS: " + allUsers.length.toString());
    });
  }

  List<User> getAllUsers() {
    return allUsers;
  }

  User getUser() {
    return user;
  }

  Future<void> _checkPermissions() async {
    if (Platform.isAndroid) {
      var permissionStatus = await PermissionHandler()
          .requestPermissions([PermissionGroup.location]);

      locationPermissionStatus = permissionStatus[PermissionGroup.location];

      if (locationPermissionStatus != PermissionStatus.granted) {
        return Future.error(Exception("Location permission not granted"));
      }
    }
  }
}
