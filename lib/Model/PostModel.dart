class Post {
  String postText;
  String userName;
  double angleFacing;
  double distance;

  Post(this.postText, this.userName, this.angleFacing, this.distance);


  Post.fromJson(Map<dynamic, dynamic> json):
    postText = json['PostText'].toString(),
    userName = json['UserName'].toString(),
    angleFacing = json['AngleFacing'].toDouble(),
    distance = json['Distance'].toDouble();


   Map<dynamic, dynamic> toJson() =>  {
   'PostText' : postText,
   'UserName' : userName,
   'AngleFacing' : angleFacing,
   'Distance' : distance
 };

}