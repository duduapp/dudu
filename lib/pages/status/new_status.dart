import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fastodon/models/vote.dart';
import 'package:fastodon/utils/dialog_util.dart';
import 'package:fastodon/widget/publish/status_reply_info.dart';
import 'package:fastodon/widget/publish/vote_display.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fastodon/public.dart';

import 'package:fastodon/models/my_account.dart';
import 'package:fastodon/models/owner_account.dart';
import 'package:fastodon/models/article_item.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widget/publish/new_status_publish_level.dart';

class NewStatus extends StatefulWidget {
  final StatusItemData replyTo;
  final dynamic scheduleInfo;

  NewStatus({this.replyTo,this.scheduleInfo});

  @override
  _NewStatusState createState() => _NewStatusState();
}

class _NewStatusState extends State<NewStatus> {
  final TextEditingController _controller = new TextEditingController();
  final TextEditingController _wornController = new TextEditingController();
  OwnerAccount _myAcc;
  bool _hasWarning = false;
  Icon _articleRange = Icon(Icons.public, size: 30);
  String _visibility = 'public';
  List<String> images = [];
  Map<String, String> imageTitles = {};
  Map<String, String> imageIds = {};
  Vote vote;
  DateTime scheduledAt;
  bool sensitive = false;
  String replyToId;

  int counter = 0;
  static const Map<String, IconData> visibilityIcons = {
    'public': Icons.public,
    'unlisted': Icons.vpn_lock,
    'private': Icons.lock,
    'direct': Icons.sms
  };

  @override
  void initState() {
    super.initState();
    // 隐藏登录弹出页
    MyAccount acc = new MyAccount();
    OwnerAccount accMsg = acc.getAcc();
    if (accMsg == null) {
      _getMyAccount();
    } else {
      setState(() {
        _myAcc = accMsg;
      });
    }
    //_getEmojis();

    if (widget.replyTo != null) {
      replyToId = widget.replyTo.id;
    }
    if (widget.replyTo != null) {
      _controller.text = getMentionString();
    }

    if (widget.scheduleInfo != null) {
      _loadFromScheduleInfo(widget.scheduleInfo);
    } else {
      _loadFromDraft();
    }
  }

  Future<void> _getEmojis() async {
    Request.get(url: Api.CustomEmojis).then((data) {
      print(data);
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
    prefs.setString(_spKey('warning'), _wornController.text);
    prefs.setString(_spKey('visibility'), _visibility);
    prefs.setStringList(_spKey('images'), images);
    prefs.setString(_spKey('image_titles'), json.encode(imageTitles));
    prefs.setString(_spKey('image_ids'), json.encode(imageIds));
    if (vote != null) {
      prefs.setStringList(_spKey('vote_options'), vote.getOptions());
      prefs.setInt(_spKey('vote_expires_in'), vote.expiresIn);
      prefs.setBool(_spKey('multi_choice'), vote.multiChoice);
    }
    prefs.setString(_spKey('scheduled_at'), scheduledAt.toIso8601String());
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
      _wornController.text = prefs.getString(_spKey('warning'));
      _hasWarning = prefs.getBool(_spKey('has_warning'));
      _visibility = prefs.getString(_spKey('visibility'));
      _articleRange = Icon(
        visibilityIcons[_visibility],
        size: 30,
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
      scheduledAt = timeStr != null ? DateTime.parse(timeStr): null;
      if (scheduledAt.difference(DateTime.now()).inSeconds < 300) {
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
    _wornController.text = params['spoiler_text'];
    _visibility = params['visibility'];
    _articleRange = Icon(
      visibilityIcons[_visibility],
      size: 30,
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
      vote = Vote.create(List<String>.from(poll['options']), poll['expires_in'], poll['multiple']);
    }

    scheduledAt = DateTime.parse(info['scheduled_at']);
    sensitive = params['sensitive'];
    replyToId = params['in_reply_to_id'];
    counter = _controller.text.length;

    setState(() {});

  }

  Future<bool> _onWillPop() async {
    if (_controller.text.isNotEmpty ||
        images.length > 0 ||
        (vote != null && vote.canCreate())) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text('是否保存本次编辑'),
              actions: <Widget>[
                FlatButton(
                  child: Text('不保留'),
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    _clearDraft();
                    AppNavigate.pop(context);
                    AppNavigate.pop(context);
                  },
                ),
                FlatButton(
                  child: Text('保留'),
                  onPressed: () {
                    _saveToDraft();
                    AppNavigate.pop(context);
                    AppNavigate.pop(context);
                  },
                )
              ],
            );
          });
      return false;
    }
    return true;
  }

  Future<void> _getMyAccount() async {
    Request.get(url: Api.OwnerAccount).then((data) {
      OwnerAccount account = OwnerAccount.fromJson(data);
      MyAccount saveAcc = new MyAccount();
      saveAcc.setAcc(account);
      setState(() {
        _myAcc = account;
      });
    });
  }

  showToast(String str) {
    Fluttertoast.showToast(
        msg: str,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: MyColor.error,
        textColor: MyColor.loginWhite,
        fontSize: 16.0);
  }

  Future<void> _pushNewToot() async {
    if (scheduledAt != null && scheduledAt.difference(DateTime.now()).inSeconds < 300) {
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
    paramsMap['spoiler_text'] = _wornController.text;
    paramsMap['status'] = _controller.text;
    paramsMap['visibility'] = _visibility;
    paramsMap['sensitive'] = sensitive;



    try {
       Request.post(url: Api.status, params: paramsMap).then((data) {
        StatusItemData newItem = StatusItemData.fromJson(data);
        if (scheduledAt != null) {
          eventBus.emit(EventBusKey.scheduledStatusPublished);
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
      response = await Request.post(url: Api.attachMedia, params: formData);
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
          url: Api.attachMedia + '/' + fileId, params: paramsMap);
      print(response);
    }
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    if (images.length < 4) addImage(image);
    print(image);
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

  Widget worningWidge() {
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
            controller: _wornController,
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
                  leftIcon: Icon(Icons.public, size: 30),
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
                  leftIcon: Icon(Icons.vpn_lock, size: 30),
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
                  leftIcon: Icon(Icons.lock, size: 30),
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
                  leftIcon: Icon(Icons.sms, size: 30),
                  onSelect: (Icon icons) {
                    setState(() {
                      _articleRange = icons;
                    });
                    _visibility = 'direct';
                  },
                  currentIcon: _articleRange,
                ),
                SizedBox(height: Screen.bottomSafeHeight(context))
              ]);
        });
  }

  showVoteDialog() {
    Vote newVote = Vote();
    if (vote != null) {
      newVote = vote.clone();
    }
    var color = Theme.of(context).toggleableActiveColor;
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: AlertDialog(
                  insetPadding: EdgeInsets.only(top: 30, left: 0, right: 0),
                  title: Text('创建投票'),
                  content: Theme(
                    data: ThemeData(primaryColor: color),
                    child: Container(
                      width: Screen.width(context) * 0.75,
                      padding: EdgeInsets.all(0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: Screen.width(context) * 0.6,
                            child: TextField(
                              maxLines: null,
                              maxLength: 25,
                              controller: newVote.option1Controller,
                              decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.only(left: 10, right: 10),
                                  hintText: '选择1',
                                  counterText: '',
                                  border: new OutlineInputBorder(
                                      borderSide:
                                          new BorderSide(color: Colors.teal)),
                                  labelText: '选择1'),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: Screen.width(context) * 0.6,
                            child: TextField(
                              maxLength: 25,
                              maxLines: null,
                              controller: newVote.option2Controller,
                              decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.only(left: 10, right: 10),
                                  hintText: '选择2',
                                  counterText: "",
                                  border: new OutlineInputBorder(
                                      borderSide:
                                          new BorderSide(color: Colors.teal)),
                                  labelText: '选择2'),
                            ),
                          ),
                          if (newVote.option3Enabled)
                            SizedBox(
                              height: 10,
                            ),
                          if (newVote.option3Enabled)
                            Row(children: <Widget>[
                              Container(
                                width: Screen.width(context) * 0.6,
                                child: TextField(
                                  maxLength: 25,
                                  maxLines: null,
                                  controller: newVote.option3Controller,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.only(left: 10, right: 10),
                                      hintText: '选择3',
                                      counterText: "",
                                      border: new OutlineInputBorder(
                                          borderSide: new BorderSide(
                                              color: Colors.teal)),
                                      labelText: '选择3'),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(0),
                                child: IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    newVote.removeOption3();
                                    setState(() {});
                                  },
                                ),
                              )
                            ]),
                          if (newVote.option4Enabled)
                            SizedBox(
                              height: 10,
                            ),
                          if (newVote.option4Enabled)
                            Row(children: <Widget>[
                              Container(
                                width: Screen.width(context) * 0.6,
                                child: TextField(
                                  maxLength: 25,
                                  maxLines: null,
                                  controller: newVote.option4Controller,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.only(left: 10, right: 10),
                                      hintText: '选择4',
                                      counterText: '',
                                      border: new OutlineInputBorder(
                                          borderSide: new BorderSide(
                                              color: Colors.teal)),
                                      labelText: '选择4'),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(0),
                                child: IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    newVote.removeOption4();
                                    setState(() {});
                                  },
                                ),
                              )
                            ]),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: <Widget>[
                              OutlineButton(
                                onPressed: () {
                                  newVote.addOption();
                                  setState(() {});
                                },
                                child: Text('添加选择'),
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              DropdownButton(
                                value: newVote.expiresInString,
                                onChanged: (String newValue) {
                                  newVote.expiresIn =
                                      Vote.voteOptionsInSeconds[newValue];

                                  setState(() {
                                    newVote.expiresInString = newValue;
                                  });
                                },
                                items: Vote.voteOptions
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(0),
                                child: Checkbox(
                                  value: newVote.multiChoice,
                                  onChanged: (value) {
                                    setState(() {
                                      newVote.multiChoice = value;
                                    });
                                  },
                                ),
                              ),
                              Text('多个选择')
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('取消'),
                      onPressed: () {
                        //vote = null;
                        AppNavigate.pop(context);
                      },
                    ),
                    FlatButton(
                      child: Text('确定'),
                      onPressed: () {
                        if (newVote.canCreate()) {
                          vote = newVote;
                          createVote();
                          AppNavigate.pop(context);
                        }
                      },
                    )
                  ],
                ),
              );
            },
          );
        });
  }

  // statefulbuild 里面的setstate是更新自己组件的，外层组件用这个方法
  createVote() {
    setState(() {});
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
    var mentionStr = '@' + widget.replyTo.account.acct + ' ';
    for (Map mention in widget.replyTo.mentions) {
      mentionStr += '@' + mention['acct'] + ' ';
    }
    return mentionStr;
  }

  @override
  Widget build(BuildContext context) {
    PopupMenu.context = context;
    var inputFilledColor = Theme.of(context).inputDecorationTheme.fillColor;
    var primaryColor = Theme.of(context).primaryColor;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.replyTo == null ? '发嘟' : '回复'),
          centerTitle: true,
          actions: <Widget>[
            Container(
              child: Text(StringUtil.displayName(_myAcc)),
              padding: EdgeInsets.only(top: 20, right: 10),
            ),
            Container(
              padding: EdgeInsets.only(top: 5, bottom: 5, right: 10),
              child: ClipRRect(
                child: CachedNetworkImage(
                  imageUrl: _myAcc.avatarStatic,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ],
        ),
        resizeToAvoidBottomInset: true,
        body: Container(
          child: Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: <Widget>[
              Container(
                height: double.infinity,
                color: inputFilledColor,
                padding: EdgeInsets.only(bottom: 50),
                child: SingleChildScrollView(
                  child: Container(
                    child: Column(
                      //   mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        worningWidge(),
                        Container(
                          // width: Screen.width(context) - 60,
                          padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                          child: TextField(
                            controller: _controller,
                            onChanged: (value) {
                              setState(() {
                                counter = value.length > 500
                                    ? 500
                                    : value.length; //当500时可能值会变成501
                              });
                            },
                            autofocus: true,
                            maxLength: 500,
                            maxLines: null,
                            decoration: InputDecoration(
                                hintText: '有什么新鲜事',
                                counterText: '',
                                disabledBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                labelStyle: TextStyle(fontSize: 16)),
                          ),
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
              Container(
                color: primaryColor,
                padding: EdgeInsets.fromLTRB(10, 5, 15, 5),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.photo, size: 30),
                            onPressed: vote != null
                                ? null
                                : () {
                                    getImage();
                                  },
                            disabledColor: Colors.grey,
                          ),
                          InkWell(
                            onTap: () {
                              showBottomSheet();
                            },
                            child: _articleRange,
                          ),
                          if (images.isNotEmpty)
                            IconButton(
                              icon: sensitive ? Icon(Icons.visibility_off,color: Colors.blue,):Icon(Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  sensitive = !sensitive;
                                });
                              },
                            ),
                          IconButton(
                            icon: Icon(Icons.list),
                            onPressed: images.length > 0
                                ? null
                                : () {
                                    showVoteDialog();
                                  },
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _hasWarning = !_hasWarning;
                              });
                            },
                            child: Text('cw',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                          ),
                          IconButton(
                            onPressed: () {
                              DatePicker.showDateTimePicker(context,
                                  showTitleActions: true,
                                  minTime:
                                      DateTime.now().add(Duration(minutes: 8)),
                                  maxTime: null,
                                  onChanged: (date) {}, onConfirm: (date) {
                                  if (date.difference(DateTime.now()).inSeconds > 300) {
                                    setState(() {
                                      scheduledAt = date;
                                    });
                                  } else {
                                    DialogUtils.toastErrorInfo('时间必须是五分钟后');
                                    setState(() {
                                      scheduledAt = null;
                                    });
                                  }
                              },
                                  onCancel: () {
                                    setState(() {
                                      scheduledAt = null;
                                    });
                                  },
                                  currentTime: scheduledAt ??
                                      DateTime.now().add(Duration(minutes: 10)),
                                  locale: LocaleType.zh);
                            },
                            icon: Icon(
                              Icons.access_time,
                              color: scheduledAt != null
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                          )
                        ],
                      ),
                      Text(counter.toString()),
                      RaisedButton(
                        onPressed: () {
                          if (_controller.text.length == 0 &&
                              images.length == 0) {
                            showToast("说点什么吧");
                          } else {
                            for (String image in images) {
                              if (imageIds[image] == null) {
                                showToast("请等待图片上传完毕");
                                return;
                              }
                            }
                            _pushNewToot();
                          }
                        },
                        child: Text('嘟嘟!'),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
      imageView =  CachedNetworkImage(imageUrl: path,);
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
                width: Screen.width(context),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    '取消',
                    style: TextStyle(color: color),
                  ),
                  onPressed: () => AppNavigate.pop(context),
                ),
                FlatButton(
                  child: Text(
                    '确定',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    imageTitles[file] = controller.text;
                    updateImageTitle(file, controller.text);
                    AppNavigate.pop(context);
                  },
                )
              ],
            ),
          );
        });
  }
}
