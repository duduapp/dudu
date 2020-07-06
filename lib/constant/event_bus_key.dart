class EventBusKey {
  static String ShowLoginWidget = 'ShowLoginWidget'; // 弹出登录页面
  static String HidePresentWidegt = 'LoginSuccess'; // 登录成功后，关闭登录页面
  static String LoadLoginMegSuccess = 'StorageSuccess';  // 从本地查询到登录信息


  static String muteAccount = 'muteAccount';// 隐藏某人推文
  static String blockAccount = 'blockAccount';// 屏蔽某人推文

  static String accountUpdated = 'accountUpdated';

  static String scheduledStatusPublished = 'scheduledStatusPublished';
  static String scheduledStatusDeleted = 'scheduledStatusDeleted';

  static String userUnmuted = 'userUnmuted';
  static String userUnblocked = 'userUnblocked';
  static String domainUnblocked = 'domainUnblocked';

  static String filterEdited = 'filterEdited';
}
