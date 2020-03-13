// Help:
// https://medium.com/flutter/some-options-for-deserializing-json-with-flutter-7481325a4450

class User {
  const User({this.userName, this.uuid, this.distance, this.direction});

  final String userName;
  final String uuid;
  final double distance;
  final double direction;

  factory User.fromJson(Map<dynamic, dynamic> json) {
    return User(
      userName: json['UserName'],
      uuid: json['UUID'],
      distance: 0,
      direction: 0

    );
  }

  Map<dynamic, dynamic> toJson() => {
    'UUID': uuid,
    "UserName": userName
  };


}