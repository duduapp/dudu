import 'package:dudu/constant/app_config.dart';
import 'package:dudu/db/tb_cache.dart';
import 'package:dudu/db/tb_instance.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

import 'package:path/path.dart';

class DBProvider {
  static final DBProvider _instance = DBProvider._internal();
  static Database database;

  factory DBProvider() {
    return _instance;
  }

  Future<Database> getDatabase() async {
    if (database == null) {
      var databasesPath = await getDatabasesPath();
      String path = join(databasesPath, AppConfig.dbName);

      var adb = await openDatabase(path, version: 1,
          onCreate: (Database db, int version) async {
        await db.execute("CREATE TABLE ${CacheColumn.table}("
            "${CacheColumn.account} Text,"
            "${CacheColumn.tag} TEXT,"
            "${CacheColumn.content} TEXT,"
            "${CacheColumn.time} INTEGER"
            ")");

        await db.execute(
            "CREATE UNIQUE INDEX ${CacheColumn.table}U1 ON ${CacheColumn.table}(${CacheColumn.account},${CacheColumn.tag})");

        await db.execute("CREATE TABLE ${InstanceColumn.table}("
            "${InstanceColumn.account} TEXT,"
            "${InstanceColumn.instance} Text"
            ")");

        await db.execute(
            "CREATE UNIQUE INDEX ${InstanceColumn.table}U1 ON ${InstanceColumn.table}(${InstanceColumn.account},${InstanceColumn.instance})");

        await db.insert(
            CacheColumn.table,
            TbCache(
                    account: '',
                    tag: 'http://api.idudu.fans/static/instances',
                    content:
                        'help.dudu.today\nmastodon.online\nmstdn.social\nmao.mastodonhub.com\n')
                .toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);

        await db.insert(
            CacheColumn.table,
            TbCache(
                    account: '',
                    tag: 'https://help.dudu.today/api/v1/instance',
                    content:
                        r'{"uri":"help.dudu.today","title":"“嘟嘟”APP使用交流FAQ实例","short_description":"长毛象第三方客户端“嘟嘟”APP的用户解惑答疑反馈建议的实例。","description":"不需要“注册”，直接点“登录”即可以guestID身份访问实例，ID所有权归本实例所有，请围绕嘟嘟APP使用中的问题和建议发言，不欢迎其他议题，请勿滥用和作为私有账号使用。","email":"admin@dudu.today","version":"3.2.0","urls":{"streaming_api":"wss://help.dudu.today"},"stats":{"user_count":13,"status_count":5,"domain_count":9},"thumbnail":"https://help.dudu.today/system/site_uploads/files/000/000/003/original/%E5%BE%AE%E4%BF%A1%E5%9B%BE%E7%89%87_20201110165322.png?1605002149","languages":["en"],"registrations":false,"approval_required":false,"invites_enabled":false,"contact_account":{"id":"1","username":"admin","acct":"admin","display_name":"","locked":false,"bot":false,"discoverable":null,"group":false,"created_at":"2020-10-27T06:08:20.522Z","note":"\u003cp\u003e\u003c/p\u003e","url":"https://help.dudu.today/@admin","avatar":"https://help.dudu.today/avatars/original/missing.png","avatar_static":"https://help.dudu.today/avatars/original/missing.png","header":"https://help.dudu.today/headers/original/missing.png","header_static":"https://help.dudu.today/headers/original/missing.png","followers_count":0,"following_count":0,"statuses_count":0,"last_status_at":null,"emojis":[],"fields":[]}}')
                .toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);

        await db.insert(
            CacheColumn.table,
            TbCache(
                    account: '',
                    tag: 'https://mastodon.online/api/v1/instance',
                    content:
                        r'{"uri":"mastodon.online","title":"Mastodon","short_description":"This is a brand new server run by the main developers of the project as a spin-off of mastodon.social \u003cimg draggable=\"false\" alt=\"🐘\" class=\"emojione\" src=\"https://cdn.mastodon.online/emoji/1f418.svg\" /\u003e It is not focused on any particular niche interest - everyone is welcome as long as you follow our code of conduct!","description":"","email":"staff@mastodon.online","version":"3.2.0","urls":{"streaming_api":"wss://mastodon.online"},"stats":{"user_count":23730,"status_count":302384,"domain_count":5060},"thumbnail":"https://files.mastodon.online/site_uploads/files/000/000/001/original/rio2.png","languages":["en"],"registrations":true,"approval_required":false,"invites_enabled":true,"contact_account":{"id":"1","username":"Gargron","acct":"Gargron","display_name":"Eugen (Personal)","locked":true,"bot":false,"discoverable":false,"group":false,"created_at":"2020-05-30T20:35:36.600Z","note":"\u003cp\u003eDeveloper of Mastodon and administrator of mastodon.social and mastodon.online. This is a personal account. Direct any business inquiries to \u003cspan class=\"h-card\"\u003e\u003ca href=\"https://mastodon.social/@Gargron\" class=\"u-url mention\"\u003e@\u003cspan\u003eGargron\u003c/span\u003e\u003c/a\u003e\u003c/span\u003e instead.\u003c/p\u003e","url":"https://mastodon.online/@Gargron","avatar":"https://files.mastodon.online/accounts/avatars/000/000/001/original/adef89f7c44d0498.png","avatar_static":"https://files.mastodon.online/accounts/avatars/000/000/001/original/adef89f7c44d0498.png","header":"https://files.mastodon.online/accounts/headers/000/000/001/original/257299c995e6146c.jpg","header_static":"https://files.mastodon.online/accounts/headers/000/000/001/original/257299c995e6146c.jpg","followers_count":39,"following_count":23,"statuses_count":101,"last_status_at":"2020-11-24","emojis":[],"fields":[]}}')
                .toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);

        await db.insert(
            CacheColumn.table,
            TbCache(
                account: '',
                tag: 'https://mstdn.social/api/v1/instance',
                content:
                r'{"uri":"mstdn.social","title":"Mastodon 🐘","short_description":"Discover \u0026amp; explore Mastodon with no ads and no surveillance. Publish anything you want on Mastodon: links, pictures, text, audio \u0026 video. \r\n\u003cbr /\u003e\u003cbr /\u003e\r\nAll on a platform that is community-owned and ad-free. \r\n\u003cbr /\u003e","description":"Discover \u0026amp; explore Mastodon with no ads and no surveillance. Publish anything you want on Mastodon: links, pictures, text, audio \u0026 video. \r\n\u003cbr /\u003e\u003cbr /\u003e\r\nAll on a platform that is community-owned and ad-free. \r\n\u003cbr /\u003e","email":"hello@mstdn.social","version":"3.2.1","urls":{"streaming_api":"wss://mstdn.social"},"stats":{"user_count":36562,"status_count":2624592,"domain_count":6183},"thumbnail":"https://mstdn.social/system/site_uploads/files/000/000/001/original/mstdn.social-banner-mastodon.png?1596379696","languages":["en"],"registrations":true,"approval_required":false,"invites_enabled":true,"contact_account":{"id":"5168","username":"stux","acct":"stux","display_name":"sтυx⚡","locked":false,"bot":false,"discoverable":true,"group":false,"created_at":"2019-11-03T17:29:02.770Z","note":"\u003cp\u003eSocial media needs to be fun, safe and secure again. Our team and I are working hard to keep that possible here for you♥️\u003c/p\u003e\u003cp\u003eDon’t forget: questions or any other chitchat are always welcome, we are on a social platform after all!\u003c/p\u003e","url":"https://mstdn.social/@stux","avatar":"https://mstdn.social/system/accounts/avatars/000/005/168/original/d08b8171546cbee6.gif?1573083576","avatar_static":"https://mstdn.social/system/accounts/avatars/000/005/168/static/d08b8171546cbee6.png?1573083576","header":"https://mstdn.social/system/accounts/headers/000/005/168/original/03255dcbca1b79f7.png?1596449371","header_static":"https://mstdn.social/system/accounts/headers/000/005/168/original/03255dcbca1b79f7.png?1596449371","followers_count":33737,"following_count":24409,"statuses_count":45415,"last_status_at":"2020-11-24","emojis":[{"shortcode":"patreon","url":"https://mstdn.social/system/custom_emojis/images/000/002/305/original/2c41bbb32a5f3019.png?1572886343","static_url":"https://mstdn.social/system/custom_emojis/images/000/002/305/static/2c41bbb32a5f3019.png?1572886343","visible_in_picker":true},{"shortcode":"liberapay","url":"https://mstdn.social/system/custom_emojis/images/000/008/436/original/5ff46fb3cfc9aa80.png?1573484752","static_url":"https://mstdn.social/system/custom_emojis/images/000/008/436/static/5ff46fb3cfc9aa80.png?1573484752","visible_in_picker":true},{"shortcode":"kofi","url":"https://mstdn.social/system/custom_emojis/images/000/002/306/original/c7c126610b0412b3.png?1572824459","static_url":"https://mstdn.social/system/custom_emojis/images/000/002/306/static/c7c126610b0412b3.png?1572824459","visible_in_picker":true},{"shortcode":"mastodon","url":"https://mstdn.social/system/custom_emojis/images/000/000/165/original/920653a73d7b1126.png?1582848983","static_url":"https://mstdn.social/system/custom_emojis/images/000/000/165/static/920653a73d7b1126.png?1582848983","visible_in_picker":true}],"fields":[{"name":"Patreon :patreon:","value":"\u003ca href=\"https://patreon.com/mstdn\" rel=\"me nofollow noopener noreferrer\" target=\"_blank\"\u003e\u003cspan class=\"invisible\"\u003ehttps://\u003c/span\u003e\u003cspan class=\"\"\u003epatreon.com/mstdn\u003c/span\u003e\u003cspan class=\"invisible\"\u003e\u003c/span\u003e\u003c/a\u003e","verified_at":"2020-06-14T20:54:39.335+00:00"},{"name":"LiberaPay :liberapay:","value":"\u003ca href=\"https://liberapay.com/mstdn\" rel=\"me nofollow noopener noreferrer\" target=\"_blank\"\u003e\u003cspan class=\"invisible\"\u003ehttps://\u003c/span\u003e\u003cspan class=\"\"\u003eliberapay.com/mstdn\u003c/span\u003e\u003cspan class=\"invisible\"\u003e\u003c/span\u003e\u003c/a\u003e","verified_at":null},{"name":"Ko-Fi :kofi:","value":"\u003ca href=\"https://ko-fi.com/mstdn\" rel=\"me nofollow noopener noreferrer\" target=\"_blank\"\u003e\u003cspan class=\"invisible\"\u003ehttps://\u003c/span\u003e\u003cspan class=\"\"\u003eko-fi.com/mstdn\u003c/span\u003e\u003cspan class=\"invisible\"\u003e\u003c/span\u003e\u003c/a\u003e","verified_at":null},{"name":"Support :mastodon:","value":"\u003ca href=\"https://mstdn.social/funding\" rel=\"me nofollow noopener noreferrer\" target=\"_blank\"\u003e\u003cspan class=\"invisible\"\u003ehttps://\u003c/span\u003e\u003cspan class=\"\"\u003emstdn.social/funding\u003c/span\u003e\u003cspan class=\"invisible\"\u003e\u003c/span\u003e\u003c/a\u003e","verified_at":null}]}}')
                .toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);

        await db.insert(
            CacheColumn.table,
            TbCache(
                account: '',
                tag: 'https://mao.mastodonhub.com/api/v1/instance',
                content:
                r'{"uri":"mao.mastodonhub.com","title":"猫站","short_description":"本站是Mastodon猫站实例。略略略。。。:-)","description":"本站是Mastodon猫站实例。除了猫猫，以众生碎碎念为主题。万望与人为善，勿要恶语相向。“我逛到这条热闹的街 太阳晒得我有点累 奇怪最近我爱碎碎念 但又觉得 I DON’T CARE”。:-)","email":"oohaohaohao","version":"3.2.0","urls":{"streaming_api":"wss://mao.mastodonhub.com"},"stats":{"user_count":13957,"status_count":18731499,"domain_count":4885},"thumbnail":"https://mao.mastodonhub.com/system/site_uploads/files/000/000/001/original/%E5%BE%AE%E4%BF%A1%E5%9B%BE%E7%89%87_20201110183313.png?1605004570","languages":["en"],"registrations":true,"approval_required":false,"invites_enabled":true,"contact_account":{"id":"83436","username":"wo","acct":"wo","display_name":"","locked":false,"bot":false,"discoverable":null,"group":false,"created_at":"2020-05-15T06:39:20.028Z","note":"\u003cp\u003e\u003c/p\u003e","url":"https://mao.mastodonhub.com/@wo","avatar":"https://mao.mastodonhub.com/avatars/original/missing.png","avatar_static":"https://mao.mastodonhub.com/avatars/original/missing.png","header":"https://mao.mastodonhub.com/headers/original/missing.png","header_static":"https://mao.mastodonhub.com/headers/original/missing.png","followers_count":90,"following_count":20,"statuses_count":58,"last_status_at":"2020-06-17","emojis":[],"fields":[]}}')
                .toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      });

      database = adb;
    }
    return database;
  }

  DBProvider._internal();
}
