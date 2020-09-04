import 'dart:convert';

import 'package:dudu/api/accounts_api.dart';
import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/models/local_account.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/home_page.dart';
import 'package:dudu/pages/webview/inner_browser.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/account_util.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/common/loading_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nav_router/nav_router.dart';
import 'package:http/http.dart' as http;

import 'model/app_credential.dart';
import 'model/server_item.dart';
import 'model/token.dart';
import 'server_list.dart';

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
    paramsMap['website'] = AppConfig.website;

    var response;
    try {
      response = await http.post('$hostUrl' + Api.Apps, body: paramsMap);
    } catch (e) {
      DialogUtils.showSimpleAlertDialog(context: navGK.currentState.overlay.context,text: '无法连接到服务器',onlyInfo: true);
      return;
    } finally {
      setState(() {
        _clickButton = false;
      });
    }
    



    AppCredential model = AppCredential.fromJson(json.decode(response.body));
    setState(() {
      _clickButton = false;
    });
    final result = await AppNavigate.push(InnerBrowser(hostUrl, appCredential: model,),);

    if (result == null) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    await _getToken(result, model, hostUrl);
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
      await http.post('$hostUrl' + Api.Token, body: paramsMap).then((data) async{
        Token getToken = Token.fromJson(json.decode(data.body));
        String token = '${getToken.tokenType} ${getToken.accessToken}';
        
        Request.closeHttpClient();

        LocalAccount localAccount = LocalAccount(hostUrl: hostUrl,token: token,active: true);
        await LocalStorageAccount.addLocalAccount(localAccount);
        

        LoginedUser user = new LoginedUser();
        user.loadFromLocalAccount(localAccount);

        OwnerAccount account = await AccountsApi.getMyAccount();
        user.account = account;
        await LocalStorageAccount.addOwnerAccount(account);

        await SettingsProvider().load(); // load new settings

        AccountUtil.cacheEmoji();

        pushAndRemoveUntil(HomePage());

        // eventBus.emit(EventBusKey.HidePresentWidegt);
      });
    } catch (e) {
      throw e;
      debugPrint(e);
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
  void _chooseServer(BuildContext context) async{
    ServerItem item = await AppNavigate.push(ServerList());
    if (item != null) {
      _controller.text = item.name;
      _checkInputText();
    }
  }

  Widget _showButtonLoading(BuildContext context) {
    if (_clickButton) {
      return SpinKitThreeBounce(
        color: Theme.of(context).buttonColor,
        size: 23,
      );
    }
    return Text('登录Mastodon账号',
        style: TextStyle(fontSize: 16, color: Color.fromRGBO(80, 125, 175, 1)));
  }

  void _showAboutSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                      'Mastodon（长毛象）是由多个不同的营运者独立运作的服务器（实例）彼此链接组成的分布式微博客社交网络。网友可自主访问目标实例并注册成为该实例的用户。请注意，每个实例的用户协议和交流风格是该实例的所有者（站长）所自行定义的，注册的时候应仔细了解该实例的用户协议以免误入。Mastodon实例可以由Web浏览器输入域名直接访问，或者通过第三方客户端来访问。这些客户端包括但不限于本客户端以及tusky、Twidere、Amaroq、Tootdon。另外，Mastodon.social，Mastodon.online是Mastodon官方运营的实例。'),
                )
              ],
            ),
          );
        });
  }

  Widget loadView() {

      return Scaffold(
        body: LoadingView(text: '正在加载中',),
      );
  }

  @override
  Widget build(BuildContext context) {
    return  isLoading ? loadView():
    Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: widget.showBackButton,
          backgroundColor: Colors.transparent,
        elevation: 0,
        leading: null,
      ),
        extendBodyBehindAppBar:true,
            resizeToAvoidBottomPadding: false,
        backgroundColor: Color.fromRGBO(0, 71, 122, 1),
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
                    Image.asset('assets/images/wallpaper.png'),
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
                                    hintText: '例如：mastodon.online',
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
                              color: Theme.of(context).primaryColor,
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
                                        TextStyle(color: Theme.of(context).primaryColor)),
                              ),
                            ),
                          ),
//                          InkWell(
//                            onTap: () {
//                              _chooseServer(context);
//                            },
//                            child: Container(
//                              child: Center(
//                                child: Text('选择实例',
//                                    style:
//                                        TextStyle(color: Theme.of(context).primaryColor)),
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
