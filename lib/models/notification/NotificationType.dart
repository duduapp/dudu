import 'package:dudu/l10n/l10n.dart';
import 'package:nav_router/nav_router.dart';


class NotificationType {
  static const String message = "message";
  static const String followRequest = "follow_request";
  static const String follow = "follow";
  static const String favourite = "favourite";
  static const String reblog = "reblog";
  static const String mention = "mention";
  static const String poll = "poll";

  static const List<String> allTypes =  ['follow', 'favourite', 'reblog', 'mention', 'poll', 'follow_request'];

  static  Map<String,String> get notificationDescription => {
    message: S.of(navGK.currentState.overlay.context).private_letters,
    followRequest: S.of(navGK.currentState.overlay.context).follow_request,
    follow: S.of(navGK.currentState.overlay.context).follow_me,
    reblog: S.of(navGK.currentState.overlay.context).turn_to,
    mention: S.of(navGK.currentState.overlay.context).at_mine,
    poll: S.of(navGK.currentState.overlay.context).vote
  };

}