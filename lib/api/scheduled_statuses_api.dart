
import 'package:dudu/utils/request.dart';

class ScheduledStatusesApi {
    static const String url = '/api/v1/scheduled_statuses';

    static delete(String statusId) async{
      await Request.delete(url:url+'/'+statusId,showDialog: true);
    }
}