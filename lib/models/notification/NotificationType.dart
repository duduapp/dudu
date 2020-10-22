

class NotificationType {
  static const String message = "message";
  static const String followRequest = "follow_request";
  static const String follow = "follow";
  static const String favourite = "favourite";
  static const String reblog = "reblog";
  static const String mention = "mention";
  static const String poll = "poll";

  static const List<String> allTypes =  ['follow', 'favourite', 'reblog', 'mention', 'poll', 'follow_request'];

  static const Map<String,String> notificationDescription = {
    message: '私信',
    followRequest: '关注请求',
    follow: '关注我的',
    reblog: '转嘟',
    mention: '@我的',
    poll: '投票'
  };

}