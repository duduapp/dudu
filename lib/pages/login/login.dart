import 'package:fastodon/api/accounts_api.dart';
import 'package:fastodon/models/json_serializable/owner_account.dart';
import 'package:fastodon/models/local_account.dart';
import 'package:fastodon/models/logined_user.dart';
import 'package:fastodon/models/provider/settings_provider.dart';
import 'package:fastodon/pages/home_page.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/utils/dialog_util.dart';
import 'package:fastodon/widget/common/loading_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nav_router/nav_router.dart';

import 'model/app_credential.dart';
import 'model/server_item.dart';
import 'model/token.dart';
import 'server_list.dart';
import 'web_login.dart';

class Login extends StatefulWidget {
  final bool showBackButton;

  Login({this.showBackButton = false});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _controller = new TextEditingController();
  bool _clickButton = false;

  bool isLoading = false; // 是否登录成功获取token中

  @override
  void initState() {
    super.initState();
  }

// 请求app的信息
  Future<void> _postApps(String hostUrl) async {
    setState(() {
      _clickButton = true;
    });

    Map paramsMap = Map();
    paramsMap['client_name'] = AppConfig.ClientName;
    paramsMap['redirect_uris'] = AppConfig.RedirectUris;
    paramsMap['scopes'] = AppConfig.Scopes;

    var data = await Request.post(url: '$hostUrl' + Api.Apps, params: paramsMap,showDialog: false);
    setState(() {
      _clickButton = false;
    });
    if (data == null) {
      DialogUtils.showSimpleAlertDialog(context: navGK.currentState.overlay.context,text: '无法连接到服务器',onlyInfo: true);
      return;
    }

    AppCredential model = AppCredential.fromJson(data);
    setState(() {
      _clickButton = false;
    });
    final result = await AppNavigate.push(context, WebLogin(serverItem: model, hostUrl: hostUrl),);

    if (result == null) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    _getToken(result, model, hostUrl);
  }

// 获取token，此后的每次请求都需带上此token
  Future<void> _getToken(
      String code, AppCredential serverItem, String hostUrl) async {
    Map<String, dynamic> paramsMap = Map();
    paramsMap['client_id'] = serverItem.clientId;
    paramsMap['client_secret'] = serverItem.clientSecret;
    paramsMap['grant_type'] = 'authorization_code';
    paramsMap['code'] = code;
    paramsMap['redirect_uri'] = serverItem.redirectUri;
    try {
      Request.post(url: '$hostUrl' + Api.Token, params: paramsMap,showDialog: false).then((data) async{
        Token getToken = Token.fromJson(data);
        String token = '${getToken.tokenType} ${getToken.accessToken}';
        

        LocalAccount localAccount = LocalAccount(hostUrl: hostUrl,token: token,active: true);
        await LocalStorageAccount.addLocalAccount(localAccount);
        

        LoginedUser user = new LoginedUser();
        user.loadFromLocalAccount(localAccount);

        OwnerAccount account = await AccountsApi.getMyAccount();
        user.account = account;
        await LocalStorageAccount.addOwnerAccount(account);

        await SettingsProvider().load(); // load new settings

        pushAndRemoveUntil(HomePage());

        // eventBus.emit(EventBusKey.HidePresentWidegt);
      });
    } catch (e) {
      print(e);
    }
  }

  void _checkInputText() {
    if (_controller.text == null || _controller.text.length == 0) {
      return;
    }
    String hostUrl = 'https://${_controller.text}';
    _postApps(hostUrl);
  }

// 跳转到选择节点页面
  void _chooseServer(BuildContext context) {
    AppNavigate.push(context, ServerList(), callBack: (ServerItem item) {
      if (item != null) {
        _controller.text = item.name;
        _checkInputText();
      }
    });
  }

  Widget _showButtonLoading(BuildContext context) {
    if (_clickButton) {
      return SpinKitThreeBounce(
        color: MyColor.loginPrimary,
        size: 23,
      );
    }
    return Text('登录Mastodon账号',
        style: TextStyle(fontSize: 16, color: MyColor.loginPrimary));
  }

  void _showAboutSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  width: 50,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    color: Colors.grey[300],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                      'Mastodon（官方中文译万象，网民又称长毛象）是一个免费开源的去中心化的分布式微博客社交网络。它的用户界面和操作方式跟推特类似，但是整个网络并非由单一机构运作，却是由多个由不同营运者独立运作的服务器以联邦方式交换数据而组成的去中心化社交网络。'),
                )
              ],
            ),
          );
        });
  }

  Widget loadView() {

      return LoadingView(text: '正在加载中',);
  }

  @override
  Widget build(BuildContext context) {
    return  isLoading ? loadView():
    Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBackButton,
          backgroundColor: Colors.transparent,
        elevation: 0,
      ),
        extendBodyBehindAppBar:true,
            resizeToAvoidBottomPadding: false,
        backgroundColor: MyColor.loginPrimary,
            body: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                        height: 60,
                        child: Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Center(
                            child: Text('Mastodon',
                                style: TextStyle(
                                    fontSize: 20, )),
                          ),
                        )),
                    Image.asset('image/wallpaper.png'),
                    Card(
                      margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(2))),
                      elevation: 5,
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('域名', style: TextStyle(fontSize: 16))
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: TextField(
                                controller: _controller,
                                decoration: new InputDecoration(
                                    hintText: '例如：mao.mastodonhub.com',
                                    disabledBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    labelStyle: TextStyle(fontSize: 16)),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              onPressed: () {
                                _checkInputText();
                              },
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: _showButtonLoading(context),
                              ),
                              color: MyColor.loginWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              _showAboutSheet(context);
                            },
                            child: Container(
                              child: Center(
                                child: Text('关于Mastodon',
                                    style:
                                        TextStyle(color: MyColor.loginWhite)),
                              ),
                            ),
                          ),
//                          InkWell(
//                            onTap: () {
//                              _chooseServer(context);
//                            },
//                            child: Container(
//                              child: Center(
//                                child: Text('选择域名',
//                                    style:
//                                        TextStyle(color: MyColor.loginWhite)),
//                              ),
//                            ),
//                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }
}
