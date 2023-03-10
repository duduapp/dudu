class Api {
  static String ServerList = 'https://instances.social/api/1.0/instances/list'; // 获取servrlist

  static String Apps = '/api/v1/apps'; // 注册app信息
  static String Token = '/oauth/token'; // 获取header Authorization
  static String VerifyToken = '/api/v1/apps/verify_credentials'; // 验证该header Authorization是否失效


  static String OwnerAccount = '/api/v1/accounts/verify_credentials'; // 该账号的信息

  static String accounts = '/api/v1/accounts';
  static String status = '/api/v1/statuses'; // 发送一个新文章
  static String attachMedia = '/api/v1/media';
  static String poll = '/api/v1/polls';
  static String search ='/api/v2/search';
  static String hashtagTimeline = '/api/v1/timelines/tag';
  static String Favourites = '/api/v1/favourites'; // 收藏的嘟文
  static String bookmarks = '/api/v1/bookmarks';
  static String lists = "/api/v1/lists";
  static String scheduled_status = '/api/v1/scheduled_statuses';

  // 上传媒体文件
  static String Following(arg) {
    return '/api/v1/accounts/$arg/following';
  }  // 获取一个用户关注的用户
  static String Follower(arg) {
    return '/api/v1/accounts/$arg/followers';
  }  // 获取一个用户关注的用户
  static String UersArticle(arg, pragma) {
    return '/api/v1/accounts/$arg/statuses?$pragma';
  } // 获取一个用户已经发送的嘟文

  static String Follow(arg) {
    return '/api/v1/accounts/$arg/follow';
  } // 关注某人
  static String UnFollow(arg) {
    return '/api/v1/accounts/$arg/unfollow';
  } // 取关某人
  static String Relationships = '/api/v1/accounts/relationships'; // 查看与某人的关注或者被关注情况
  static String CustomEmojis = '/api/v1/custom_emojis'; // 该节点的emojis
  static String FavouritesArticle(arg) {
    return '/api/v1/statuses/$arg/favourite'; // 收藏某个文章
  }
  static String UnFavouritesArticle(arg) {
    return '/api/v1/statuses/$arg/unfavourite'; // 取消收藏某个文章
  }
}
