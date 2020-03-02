// Help:
// https://medium.com/flutter/some-options-for-deserializing-json-with-flutter-7481325a4450


class User {
  const User({this.userName, this.uuid});

  final String userName;
  final String uuid;
  //final Map<User, double> nearbyUsers;

  factory User.fromJson(Map<dynamic, dynamic> json) {
    return User(
      userName: json['UserName'],
      uuid: json['UUID']
    );
  }

  Map<dynamic, dynamic> toJson() => {
    'UUID': uuid,
    "UserName": userName
  };


}