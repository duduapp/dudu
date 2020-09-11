import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/models/json_serializable/vote.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/utils/media_util.dart';
import 'package:dudu/utils/view/status_action_util.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/common/sized_icon_button.dart';
import 'package:dudu/widget/new_status/emoji_widget.dart';
import 'package:dudu/widget/new_status/handle_vote_dialog.dart';
import 'package:dudu/widget/new_status/status_reply_info.dart';
import 'package:dudu/widget/new_status/status_text_editor.dart';
import 'package:dudu/widget/new_status/vote_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widget/new_status/new_status_publish_level.dart';

class NewStatus extends StatefulWidget {
  final StatusItemData replyTo;
  final dynamic scheduleInfo;
  final String prepareText; // 预设的嘟嘟内容

  NewStatus({this.replyTo, this.scheduleInfo, this.prepareText});

  @override
  _NewStatusState createState() => _NewStatusState();
}

class _NewStatusState extends State<NewStatus> {
  TextEditingController _controller;
  final TextEditingController _warningController = new TextEditingController();
  OwnerAccount _myAcc;
  bool _hasWarning = false;
  Icon _articleRange = Icon(IconFont.earth,size: 26,);
  String _visibility = 'public';
  List<String> images = [];
  Map<String, String> imageTitles = {};
  Map<String, String> imageIds = {};
  Vote vote;
  DateTime scheduledAt;
  bool sensitive = false;
  String replyToId;
  bool showEmojiKeyboard = false;
  double keyboardHeight = 0;
  bool textEdited = false;
  var focusNode = new FocusNode();

  int counter = 0;

  @override
  void initState() {
    _controller = RichTextController({
      RegExp(r"\B#[a-zA-Z0-9-_]+\b"): TextStyle(color: AppConfig.buttonColor),
      RegExp(r"\B@[@\.a-zA-Z0-9-_]+\b"): TextStyle(color: AppConfig.buttonColor)
    }, onMatch: (List<String> matches) {});
    super.initState();
    // 隐藏登录弹出页
    _myAcc = LoginedUser().account;

    if (widget.replyTo != null) {
      replyToId = widget.replyTo.id;
      _visibility = widget.replyTo.visibility;
      _articleRange = Icon(AppConfig.visibilityIcons[_visibility],size: 26,);
      _controller.text = getMentionString();
      counter = _controller.text.length;
    }

    if (widget.scheduleInfo != null) {
      _loadFromScheduleInfo(widget.scheduleInfo);
    } else {
      if (widget.replyTo == null)
        _loadFromDraft();
    }

    if (widget.prepareText != null) {
      _controller.text = widget.prepareText;
    }

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          showEmojiKeyboard = false;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (widget.replyTo == null && prefs.getBool(_spKey('have_draft')) == null) {
        SettingsProvider provider =
        Provider.of<SettingsProvider>(context, listen: false);
        _visibility = provider.get('default_post_privacy');
        _articleRange = Icon(AppConfig.visibilityIcons[_visibility], size: 26,);
        sensitive = provider.get('make_media_sensitive');
      }
    });
  }

  _spKey(String str) {
    return _myAcc.acct + '/' + str;
  }

  _saveToDraft() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_spKey('have_draft'), true);
    prefs.setString(_spKey('text'), _controller.text);
    prefs.setBool(_spKey('has_warning'), _hasWarning);
    prefs.setString(_spKey('warning'), _warningController.text);
    prefs.setString(_spKey('visibility'), _visibility);
    prefs.setStringList(_spKey('images'), images);
    prefs.setString(_spKey('image_titles'), json.encode(imageTitles));
    prefs.setString(_spKey('image_ids'), json.encode(imageIds));
    if (vote != null) {
      prefs.setStringList(_spKey('vote_options'), vote.getOptions());
      prefs.setInt(_spKey('vote_expires_in'), vote.expiresIn);
      prefs.setBool(_spKey('multi_choice'), vote.multiChoice);
    }

    prefs.setString(_spKey('scheduled_at'), scheduledAt?.toIso8601String());
    prefs.setBool(_spKey('sensitive'), sensitive);
  }

  _clearDraft() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(_spKey('have_draft'));
    prefs.remove(_spKey('text'));
    prefs.remove(_spKey('has_warning'));
    prefs.remove(_spKey('warning'));
    prefs.remove(_spKey('visibility'));
    prefs.remove(_spKey('images'));
    prefs.remove(_spKey('image_titles'));
    prefs.remove(_spKey('image_ids'));
    prefs.remove(_spKey('vote_options'));
    prefs.remove(_spKey('vote_expires_in'));
    prefs.remove(_spKey('multi_choice'));
    prefs.remove(_spKey('scheduled_at'));
    prefs.remove(_spKey('sensitive'));
  }

  _loadFromDraft() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_spKey('have_draft')) != null) {
      _controller.text = prefs.getString(_spKey('text'));
      _warningController.text = prefs.getString(_spKey('warning'));
      _hasWarning = prefs.getBool(_spKey('has_warning'));
      _visibility = prefs.getString(_spKey('visibility'));
      _articleRange = Icon(
        AppConfig.visibilityIcons[_visibility],
        size: 26,
      );
      images = prefs.getStringList(_spKey('images'));
      imageTitles = Map<String, String>.from(
          json.decode(prefs.getString(_spKey('image_titles'))));
      imageIds = Map<String, String>.from(
          json.decode(prefs.getString(_spKey('image_ids'))));
      var options = prefs.getStringList(_spKey('vote_options'));
      if (options != null) {
        vote = Vote.create(
            prefs.getStringList(_spKey('vote_options')),
            prefs.getInt(_spKey('vote_expires_in')),
            prefs.getBool(_spKey('multi_choice')));
      }
      var timeStr = prefs.get(_spKey('scheduled_at'));
      scheduledAt = timeStr != null ? DateTime.parse(timeStr) : null;
      if (scheduledAt != null &&
          scheduledAt.difference(DateTime.now()).inSeconds < 300) {
        scheduledAt = null;
      }
      sensitive = prefs.getBool(_spKey('sensitive'));
      counter = _controller.text.length;
      setState(() {});
    }
  }

  _loadFromScheduleInfo(dynamic info) {
    var params = info['params'];
    _controller.text = params['text'];
    _warningController.text = params['spoiler_text'];
    _visibility = params['visibility'];
    _articleRange = Icon(
      AppConfig.visibilityIcons[_visibility],
      size: 26,
    );
    for (var media in info['media_attachments']) {
      if (media['type'] == 'image') {
        images.add(media['url']);
        imageIds[media['url']] = media['id'];
        imageTitles[media['url']] = media['description'];
      }
    }
    if (params['poll'] != null) {
      var poll = params['poll'];
      vote = Vote.create(List<String>.from(poll['options']), poll['expires_in'],
          poll['multiple']);
    }

    scheduledAt = DateTime.parse(info['scheduled_at']);
    sensitive = params['sensitive'];
    replyToId = params['in_reply_to_id'];
    counter = _controller.text.length;

    setState(() {});
  }

  bool get tootEdited {
    return (textEdited && _controller.text.isNotEmpty )||
        images.length > 0 ||
        (vote != null && vote.canCreate());
  }

  Future<bool> _onWillPop() async {
    if (tootEdited) {
      _showSaveDraftDialog();
      return false;
    }
    return true;
  }

  _showSaveDraftDialog() {
    DialogUtils.showSimpleAlertDialog(
        context: context,
        popAfter: true,
        text: '是否保留本次编辑',
        onCancel: () {
          _clearDraft();
          AppNavigate.pop();
        },
        onConfirm: () {
          _saveToDraft();
          AppNavigate.pop();
        },
        cancelText: '不保留',
        confirmText: '保留');
  }

  _onPressBack() {
    if (tootEdited) {
      _showSaveDraftDialog();
    } else {
      AppNavigate.pop();
    }
  }

  showToast(String str) {
    Fluttertoast.showToast(
        msg: str,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Theme.of(context).primaryColor,
        fontSize: 16.0);
  }

  Future<void> _pushNewToot() async {
    if (scheduledAt != null &&
        scheduledAt.difference(DateTime.now()).inSeconds < 300) {
      DialogUtils.toastErrorInfo('定时嘟文必须是五分钟后');
      return;
    }

    var mediaIds = [];
    for (String file in images) {
      var id = imageIds[file];
      if (id != null) {
        mediaIds.add(id);
      }
    }
    Map<String, dynamic> paramsMap = Map();
    paramsMap['in_reply_to_id'] = null;
    if (vote != null) {
      var poll = {
        'options': vote.getOptions(),
        'expires_in': vote.expiresIn,
        'multiple': vote.multiChoice
      };
      paramsMap['poll'] = poll;
    } else {
      paramsMap['media_ids'] = mediaIds;
    }
    if (replyToId != null) {
      paramsMap['in_reply_to_id'] = replyToId;
    }

    if (scheduledAt != null) {
      paramsMap['scheduled_at'] = scheduledAt.toIso8601String();
    }

    paramsMap['sensitive'] = false;
    paramsMap['spoiler_text'] = _warningController.text;
    paramsMap['status'] = _controller.text;
    paramsMap['visibility'] = _visibility;
    paramsMap['sensitive'] = sensitive;

    try {
      Request.post(
              url: Api.status,
              params: paramsMap,
              dialogMessage: '嘟嘟中...',
              successMessage: '嘟文已发送')
          .then((data) {
        if (data != null) {
          AppNavigate.pop();
          if (!data.containsKey('scheduled_at')) {
            SettingsProvider().homeProvider.addToListWithAnimation(data);
            if (data.containsKey('visibility') && data['visibility'] == 'public') {
              SettingsProvider().localProvider.addToListWithAnimation(data);
              SettingsProvider().federatedProvider.addToListWithAnimation(data);
            }
            StatusActionUtil.changeStatusCount(1);
          }

        }
      });
    } on DioError catch (e) {
      showToast('发送嘟嘟失败！');
    }
  }

  uoloadImage(File file) async {
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
    });
    var response;
    try {
      response = await Request.requestDio(
          url: Api.attachMedia, params: formData);
    } on DioError catch (e) {
      images.remove(file);
      Fluttertoast.showToast(msg: '文件上传失败');
      return;
    }
    String fileId = response['id'];
    if (fileId.isNotEmpty) {
      imageIds[file.path] = fileId;
      setState(() {});
    }
  }

  updateImageTitle(String file, String title) async {
    var fileId = imageIds[file];
    if (fileId != null) {
      Map<String, dynamic> paramsMap = Map();
      paramsMap['description'] = title;
      var response = await Request.put(
          url: Api.attachMedia + '/' + fileId,
          params: paramsMap,
          showDialog: false);
      debugPrint(response);
    }
  }

  Future chooseImage() async {
    var image = await MediaUtil.pickAndCompressImage();

    if (image == null) {
      return;
    }
    if (images.length < 4) addImage(image);
  }

  addImage(File file) {
    images.add(file.path);
    setState(() {});
    uoloadImage(file);
  }

  removeImage(String file) {
    images.remove(file);
    setState(() {});
  }

  Widget warningWidget() {
    if (_hasWarning == false) {
      return Container();
    }
    return Column(
      children: <Widget>[
        Container(
          height: 50,
          //    width: Screen.width(context) - 60,
          padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: TextField(
            controller: _warningController,
            decoration: InputDecoration(
                hintText: '折叠部分的警告消息',
                disabledBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                labelStyle: TextStyle(fontSize: 16)),
          ),
        ),
        new Container(
          height: 1,
          color: Colors.grey[300],
        ),
        SizedBox(height: 10)
      ],
    );
  }

  void showBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                NewStatusPublishLevel(
                  title: '公开',
                  description: '所有人可见，并且会出现在公共时间轴上',
                  leftIcon: Icon(IconFont.earth,size: 26,),
                  onSelect: (Icon icons) {
                    setState(() {
                      _articleRange = icons;
                      _visibility = 'public';
                    });
                  },
                  currentIcon: _articleRange,
                ),
                NewStatusPublishLevel(
                  title: '不公开',
                  description: '所有人可见，但不会出现在公共时间轴上',
                  leftIcon: Icon(IconFont.unlock,size: 26,),
                  onSelect: (Icon icons) {
                    setState(() {
                      _articleRange = icons;
                      _visibility = 'unlisted';
                    });
                  },
                  currentIcon: _articleRange,
                ),
                NewStatusPublishLevel(
                  title: '仅关注者',
                  description: '只有关注你的用户可以看到',
                  leftIcon: Icon(IconFont.lock,size: 26,),
                  onSelect: (Icon icons) {
                    setState(() {
                      _articleRange = icons;
                      _visibility = 'private';
                    });
                  },
                  currentIcon: _articleRange,
                ),
                NewStatusPublishLevel(
                  title: '私信',
                  description: '只有被提及的用户可以看到',
                  leftIcon: Icon(IconFont.message,size: 26,),
                  onSelect: (Icon icons) {
                    setState(() {
                      _articleRange = icons;
                    });
                    _visibility = 'direct';
                  },
                  currentIcon: _articleRange,
                ),
                SizedBox(height: ScreenUtil.bottomSafeHeight(context))
              ]);
        });
  }

  showVoteDialog() async {
    Vote newVote = await DialogUtils.showRoundedDialog(
        content: HandleVoteDialog(vote: vote), context: context);

    if (newVote != null) {
      setState(() {
        vote = newVote;
      });
    }
  }

  Widget replyInfo() {
    if (widget.replyTo == null) {
      return Container();
    } else {
      return StatusReplyInfo(widget.replyTo);
    }
  }

  // 转发时需要填的mention list
  getMentionString() {
    OwnerAccount myAccount = LoginedUser().account;
    var mentionStr;
    if (widget.replyTo.account.acct == myAccount.acct)
      mentionStr = '';
    else
     mentionStr = '@' + widget.replyTo.account.acct + ' ';
    for (Map mention in widget.replyTo.mentions) {
      if (myAccount.acct == mention['acct']) {
        continue;
      }
      mentionStr += '@' + mention['acct'] + ' ';
    }
    return mentionStr;
  }

  bool get canToot {
    if (_controller.text.length == 0 && images.length == 0) {
      return false;
    }
    for (String image in images) {
      if (imageIds[image] == null) {
       // showToast("请等待图片上传完毕");
        return false;
      }
    }
    return true;
  }


  @override
  Widget build(BuildContext context) {
    PopupMenu.context = context;
    var appbarColor = Theme.of(context).appBarTheme.color;
    var inputFilledColor = Theme.of(context).inputDecorationTheme.fillColor;
    var primaryColor = Theme.of(context).primaryColor;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(45.0),
          child: CustomAppBar(
            automaticallyImplyLeading: false,
            leading: Container(
              padding: EdgeInsets.fromLTRB(20, 15, 0, 0),
              child: GestureDetector(
                onTap: () => _onPressBack(),
                child: Text(
                  '取消',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
            titleSpacing: 0,
            backgroundColor: Color.fromRGBO(appbarColor.red - 4,
                appbarColor.green - 4, appbarColor.blue - 4, 1),
            title: Column(mainAxisSize: MainAxisSize.min,
                children: [
              Text(
                widget.replyTo == null ? '发嘟' : '回复',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                StringUtil.displayName(LoginedUser().account),
                style:
                    TextStyle(fontSize: 12, color: Theme.of(context).accentColor),
              )
            ]),
            centerTitle: true,
            actions: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(0, 8, 12,6),
                child: ButtonTheme(
                  minWidth: 60,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: RaisedButton(
                    disabledTextColor: Colors.white.withOpacity(0.5),
                    disabledColor: Theme.of(context).buttonColor.withOpacity(0.5),
                    color: Theme.of(context).buttonColor,
                    textColor: Colors.white,
                    onPressed: !canToot
                        ? null
                        : () {
                            _pushNewToot();
                          },
                    child: Text('嘟嘟'),
                  ),
                ),
              )
            ],
          ),
        ),
        resizeToAvoidBottomInset: showEmojiKeyboard ? false : true,
        body: Container(
          child: Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: <Widget>[
              Container(
                height: double.infinity,
                color: Theme.of(context).primaryColor,
                padding: EdgeInsets.only(bottom: 50),
                child: SingleChildScrollView(
                  child: Container(
                    child: Column(
                      //   mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        warningWidget(),
                        StatusTextEditor(
                          controller: _controller,
                          focusNode: focusNode,
                          onChanged: (value) {
                            setState(() {
                              textEdited = true;
                              counter = value.length > 500
                                  ? 500
                                  : value.length; //当500时可能值会变成501
                            });
                          },
                        ),
                        if (vote != null)
                          SizedBox(
                            height: 20,
                          ),
                        if (vote != null) voteView(),
                        imagesList(),
                        replyInfo(),
                      ],
                    ),
                  ),
                ),
              ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                      padding: EdgeInsets.fromLTRB(0, 0, 15, 10),
                      child: Text(
                        counter > 0 ? counter.toString() : '',
                        style: TextStyle(color: Theme.of(context).accentColor),
                      )),
                ),
                Divider(
                  height: 0,
                  color: Theme.of(context).accentColor,
                ),
                Container(
                  width: double.infinity,
                  color: Color.fromRGBO(appbarColor.red - 3,
                      appbarColor.green - 3, appbarColor.blue - 3, 1),
                  padding: EdgeInsets.fromLTRB(10, 5, 15, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedIconButton(
                        width: 35,
                        icon: Icon(IconFont.picture),
                        onPressed: vote != null
                            ? null
                            : () {
                                chooseImage();
                              },
                      ),
                      SizedIconButton(
                        onPressed: () {
                          showBottomSheet();
                        },
                        icon: _articleRange,
                      ),
                      if (images.isNotEmpty)
                        SizedIconButton(
                          icon: sensitive
                              ? Icon(
                                  IconFont.eyeClose,
                                  color: Colors.blue,
                                )
                              : Icon(IconFont.eye),
                          onPressed: () {
                            setState(() {
                              sensitive = !sensitive;
                            });
                          },
                        ),
                      SizedIconButton(
                        icon: Icon(
                          IconFont.vote,
                          size: 26,
                        ),
                        onPressed: images.length > 0
                            ? null
                            : () {
                                showVoteDialog();
                              },
                      ),
                      SizedIconButton(
                        onPressed: () {
                          setState(() {
                            _hasWarning = !_hasWarning;
                          });
                        },
                        icon: Icon(IconFont.cw,color: _hasWarning ? Theme.of(context).buttonColor: null,),
//                            child: Text('cw',
//                                style: TextStyle(
//                                    fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                      SizedIconButton(
                        onPressed: () {
                          DatePicker.showDateTimePicker(context,
                              theme: DatePickerTheme(
                                backgroundColor: Theme.of(context).primaryColor,
                                cancelStyle: TextStyle(color: Theme.of(context).textTheme.bodyText2.color),
                                itemStyle: TextStyle(color: Theme.of(context).textTheme.bodyText2.color)
                              ),
                              showTitleActions: true,
                              minTime:
                                  DateTime.now().add(Duration(minutes: 8)),
                              maxTime: null,
                              onChanged: (date) {}, onConfirm: (date) {
                            if (date.difference(DateTime.now()).inSeconds >
                                300) {
                              setState(() {
                                scheduledAt = date;
                              });
                            } else {
                              DialogUtils.toastErrorInfo('时间必须是五分钟后');
                              setState(() {
                                scheduledAt = null;
                              });
                            }
                          }, onCancel: () {
                            setState(() {
                              scheduledAt = null;
                            });
                          },
                              currentTime: scheduledAt ??
                                  DateTime.now().add(Duration(minutes: 10)),
                              locale: LocaleType.zh);
                        },
                        icon: Icon(
                          IconFont.time,
                          color: scheduledAt != null
                              ? Colors.blue
                              : null,
                        ),
                      ),
                      SizedIconButton(
                        icon: Icon(IconFont.emoji),
                        onPressed: _toggleEmoji,
                      )
                    ],
                  ),
                ),
                Visibility(
                  visible: showEmojiKeyboard,
                  child: SizedBox(
                    height: keyboardHeight,
                    child: EmojiKeyboard(
                        onChoose: (e) {
                          setState(() {
                            _controller.text =
                                _controller.text + ' :' + e + ':';
                            counter = _controller.text.length;
                          });
                        }),
                  ),
                )
              ]),
            ],
          ),
        ),
      ),
    );
  }

  _toggleEmoji() {
    setState(() {
      showEmojiKeyboard = !showEmojiKeyboard;
    });

    var kHeight = MediaQuery.of(context).viewInsets.bottom;
    // keyboard is shown up
    if (kHeight > 0) {
      FocusScope.of(context).unfocus();
      if (kHeight != keyboardHeight) {
        setState(() {
          keyboardHeight = kHeight;
        });
      }
    } else {
      FocusScope.of(context).requestFocus(focusNode);
    }
  }

  Widget voteView() {
    var color = Theme.of(context).popupMenuTheme.color;
    var btnKey = GlobalKey();
    PopupMenu menu = PopupMenu(
      backgroundColor: color,
      lineColor: color,
      items: [
        MenuItem(title: '编辑', image: Icon(Icons.edit)),
        MenuItem(title: '删除', image: Icon(Icons.delete))
      ],
      onClickMenu: (item) {
        if (item.menuTitle == '删除') {
          vote = null;
          setState(() {});
        } else if (item.menuTitle == '编辑') {
          showVoteDialog();
        }
      },
    );
    return InkWell(
      key: btnKey,
      onTap: () => menu.show(widgetKey: btnKey),
      child: VoteDisplay(vote),
    );
  }

  Widget imagesList() {
    if (images.length == 0)
      return SizedBox(
        height: 0,
      );
    List<Widget> lists = [];
    for (int i = 0; i < images.length; i++) {
      lists.add(imageDisplayView(images[i]));
      lists.add(SizedBox(
        width: 10,
      ));
    }

    return Container(
      //width: Screen.width(context) - 60,
      padding: EdgeInsets.only(left: 15, right: 10),
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: lists,
      ),
    );
  }

  Widget imageDisplayView(String path) {
    var color = Theme.of(context).popupMenuTheme.color;
    var btnKey = GlobalKey();
    PopupMenu menu = PopupMenu(
      backgroundColor: color,
      lineColor: color,
      items: [
        MenuItem(title: '辅助标题', image: Icon(Icons.accessible)),
        MenuItem(title: '删除', image: Icon(Icons.delete))
      ],
      onClickMenu: (item) {
        if (item.menuTitle == '删除') {
          removeImage(path);
        } else if (item.menuTitle == '辅助标题') {
          openImageTitleDialog(path);
        }
      },
    );
    Widget imageView;
    if (StringUtil.isUrl(path)) {
      imageView = CachedNetworkImage(
        imageUrl: path,
      );
    } else {
      imageView = Image.file(File(path));
    }
    return InkWell(
      key: btnKey,
      onTap: () {
        menu.show(
          widgetKey: btnKey,
        );
      },
      child: Stack(
        children: [
          Container(
              width: 100,
              height: 100,
              child: FittedBox(
                child: imageView,
                fit: BoxFit.fitWidth,
              )),
          if (imageIds[path] == null)
            Center(
              widthFactor: 1.5,
              child: JumpingText(
                '上传中...',
                style: TextStyle(color: Colors.white),
              ),
            )
        ],
      ),
    );
  }

  openImageTitleDialog(String file) {
    var imageTitle = imageTitles[file];
    TextEditingController controller = TextEditingController(text: imageTitle);
    var color = Theme.of(context).toggleableActiveColor;
    showDialog(
        context: context,
        builder: (context) {
          return Theme(
            data: ThemeData(primaryColor: color),
            child: AlertDialog(
              content: Container(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: '为视觉障碍人士添加文字说明',
                  ),
                  maxLength: 450,
                  maxLines: null,
                ),
                width: ScreenUtil.width(context),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    '取消',
                    style: TextStyle(color: color),
                  ),
                  onPressed: () => AppNavigate.pop(),
                ),
                FlatButton(
                  child: Text(
                    '确定',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    imageTitles[file] = controller.text;
                    updateImageTitle(file, controller.text);
                    AppNavigate.pop();
                  },
                )
              ],
            ),
          );
        });
  }
}
