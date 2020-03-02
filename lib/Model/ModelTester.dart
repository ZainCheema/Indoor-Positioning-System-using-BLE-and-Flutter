import 'PostModel.dart';
import 'package:umbrella/utils.dart';
import 'package:umbrella/widgets.dart';

class ModelTester {
  static List<Map<dynamic, dynamic>> dummyUserJsonList = [
    {'UUID': '1974619274619246', 'UserName': 'CoolMan'},
    {'UUID': '1636453646464', 'UserName': 'DayDude'},
    {'UUID': '136564567457', 'UserName': 'GooGirl'},
    {'UUID': '4756784574567', 'UserName': 'Nanaonsha'},
    {'UUID': '147907503497850', 'UserName': 'FudgeMother'}
  ];

  static var dummyCommentsJson = [
    {
      'User': dummyUserJsonList[randomNumber(0, 4)],
      'PostID': '12132342312',
      'CommentText': 'Thats a banger of a song tbh',
      'CommentID': '1078120740127',
      'Upvotes': 0
    },
    {
      'User': dummyUserJsonList[randomNumber(0, 4)],
      'PostID': '12132342312',
      'CommentText': 'What song is it?',
      'CommentID': '10781207421827',
      'Upvotes': 0
    },
    {
      'User': dummyUserJsonList[randomNumber(0, 4)],
      'PostID': '12132342312',
      'CommentText': 'I stan Kali',
      'CommentID': '1078120740127',
      'Upvotes': 0
    },
    {
      'User': dummyUserJsonList[randomNumber(0, 4)],
      'PostID': '12132342312',
      'CommentText': 'Thats a banger of a song tbh',
      'CommentID': 'cringe',
      'Upvotes': 0
    },
  ];

  static var dummyPostJson = {
    'User': dummyUserJsonList[randomNumber(0, 4)],
    'PostID': '12132342312',
    'PostText':
        'Dont you love when i come around? This feels like summer, just be my lover, boy you lead me to paradise',
    'Comments': dummyCommentsJson
  };

  static generateDummyPosts(int x) {
    List<PostCard> dummyPostCards = new List<PostCard>();

    for (int i = 0; i < x; i++) {
      dummyPostCards.add(PostCard(post: Post.fromJson(dummyPostJson)));
    }

    return dummyPostCards;
  }
}
