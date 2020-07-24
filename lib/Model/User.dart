// Help:
// https://medium.com/flutter/some-options-for-deserializing-json-with-flutter-7481325a4450

class User {
  const User({this.userName, this.uuid, this.facing, this.distance, this.direction});

  final String userName;
  final String uuid;
  final String facing;
  final double distance;
  final int direction;

  factory User.fromJson(Map<dynamic, dynamic> json) {
    return User(
      userName: json['UserName'],
      uuid: json['UUID'],
      facing: json['Facing'],
      distance: 0,
      direction: 0
    );
  }

  Map<dynamic, dynamic> toJson() => {
    'UUID': uuid,
    'UserName': userName,
    'Facing': facing,
    'Direction': direction
  };

}