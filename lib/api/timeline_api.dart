import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/utils/request.dart';

class TimelineApi {
  static const String notificationUrl = '/api/v1/notifications';
  static const String conversations = '/api/v1/conversations';
  static const String home = '/api/v1/timelines/home';
  static const String local = '/api/v1/timelines/public?local=true';
  static const String federated = '/api/v1/timelines/public';

  static String get notification {
    var displayType = SettingsProvider().settings['notification_display_type'];
    var notificationTypes = [
      'follow',
      'favourite',
      'reblog',
      'mention',
      'poll',
      'follow_request'
    ];
    notificationTypes.removeWhere((element) => displayType.contains(element));
    return Request.buildGetUrl(
        notificationUrl, {'exclude_types': notificationTypes});
  }

  static _include_types(List retain) {
    var notificationTypes = ['follow', 'favourite', 'reblog', 'mention', 'poll', 'follow_request'];
     notificationTypes.removeWhere((element) => retain.contains(element));
    return {'exclude_types':notificationTypes};
  }

  static String get followRquest {
   return Request.buildGetUrl(notificationUrl, _include_types(['follow_request']));
  }

  static String get mention {
    return Request.buildGetUrl(notificationUrl, _include_types(['mention']));
  }

  static String get otherNotification {
    return Request.buildGetUrl(notificationUrl, _include_types(['follow', 'favourite', 'reblog', 'poll']));
  }




}
