

import 'package:fastodon/public.dart';

class NotificationApi {
    static String url = '/api/v1/notifications';

    static clear() async{
      await Request.post(url: '$url/clear');
    }
}