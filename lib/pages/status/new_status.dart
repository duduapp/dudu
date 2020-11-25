import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/models/json_serializable/media_attachment.dart';
import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/models/json_serializable/vote.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/models/status/picked_media.dart';
import 'package:dudu/pages/status/picked_media_preview.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/utils/media_util.dart';
import 'package:dudu/utils/themes.dart';
import 'package:dudu/utils/view/status_action_util.dart';
import 'package:dudu/widget/common/bottom_sheet_item.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/common/sized_icon_button.dart';
import 'package:dudu/widget/dialog/loading_dialog.dart';
import 'package:dudu/widget/new_status/emoji_widget.dart';
import 'package:dudu/widget/new_status/handle_vote_dialog.dart';
import 'package:dudu/widget/new_status/picked_media_display.dart';
import 'package:dudu/widget/new_status/status_reply_info.dart';
import 'package:dudu/widget/new_status/status_text_editor.dart';
import 'package:dudu/widget/new_status/vote_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart' as picker;

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
  Icon _articleRange = Icon(
    IconFont.earth,
    size: 26,
  );
  String _visibility = 'public';
  List<String> images = [];
  Map<String, String> imageTitles = {};
  Map<String, String> imageIds = {};
  List<PickedMedia> medias = [];
  Vote vote;
  DateTime scheduledAt;
  bool sensitive = false;
  String replyToId;
  bool showEmojiKeyboard = false;
  double keyboardHeight = 0;
  bool textEdited = false;
  int cursorPositionWhenUnfocus = 0;
  var focusNode = new FocusNode();

  int counter = 0;

  @override
  void initState() {
    _controller = RichTextController({
      RegExp(r"#[\u4E00-\u9FCC_a-zA-Z]+", unicode: true, multiLine: true):
          TextStyle(color: AppConfig.buttonColor),
      RegExp(r"\B@[@\.a-zA-Z0-9-_]+\b"): TextStyle(color: AppConfig.buttonColor)
    }, onMatch: (List<String> matches) {});
    super.initState();
    // 隐藏登录弹出页
    _myAcc = LoginedUser().account;

    if (widget.replyTo != null) {
      replyToId = widget.replyTo.id;
      _visibility = widget.replyTo.visibility;
      _articleRange = Icon(
        AppConfig.visibilityIcons[_visibility],
        size: 26,
      );
      _controller.text = getMentionString();
      counter = _controller.text.length;
    }

    if (widget.scheduleInfo != null) {
      _loadFromScheduleInfo(widget.scheduleInfo);
    } else {
      if (widget.replyTo == null) _loadFromDraft();
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (widget.replyTo == null &&
          prefs.getBool(_spKey('have_draft')) == null) {
        SettingsProvider provider =
            Provider.of<SettingsProvider>(context, listen: false);
        _visibility = provider.get('default_post_privacy');
        _articleRange = Icon(
          AppConfig.visibilityIcons[_visibility],
          size: 26,
        );
        sensitive = provider.get('make_media_sensitive');
      }
    });
  }

  _spKey(String str) {
    return _myAcc.acct + '/' + str;
  }

  _saveToDraft() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> imageLocalIds = [];
    for (PickedMedia media in medias) {
      if (media.local != null) {
        imageLocalIds.add(media.local.id);
      }
    }
    prefs.setBool(_spKey('have_draft'), true);
    prefs.setString(_spKey('text'), _controller.text);
    prefs.setBool(_spKey('has_warning'), _hasWarning);
    prefs.setString(_spKey('warning'), _warningController.text);
    prefs.setString(_spKey('visibility'), _visibility);

    //   prefs.setString(_spKey('image_titles'), json.encode(imageTitles));
    prefs.setStringList(_spKey('media_ids'), imageLocalIds);
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
    prefs.remove(_spKey('media_ids'));
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
      var mediaIds = prefs.getStringList(_spKey('media_ids'));
      for (String mediaId in mediaIds) {
        picker.AssetEntity entity = await picker.AssetEntity.fromId(mediaId);
        if ((await entity.file) != null) {
          medias.add(PickedMedia(local: entity));
        }
      }
      // imageTitles = Map<String, String>.from(
      //     json.decode(prefs.getString(_spKey('image_titles'))));

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
    var params;
    if (info.containsKey('params')) {
        params = info['params'];
        _controller.text = params['text'];
    } else {
      params = info;
      _controller.text = StringUtil.removeAllHtmlTags(params['content']);
    }


    _warningController.text = params['spoiler_text'];
    _visibility = params['visibility'];
    _articleRange = Icon(
      AppConfig.visibilityIcons[_visibility],
      size: 26,
    );
    for (var media in info['media_attachments']) {
      medias.add(PickedMedia(remote: MediaAttachment.fromJson(media)));
    }
    if (params['poll'] != null) {
      var poll = params['poll'];
      List<String> options = [];
      var expiresIn;
      if (info.containsKey('params')) {
        options = List<String>.from(poll['options']);
        expiresIn = poll['expires_in'];
      } else {
        for (var opt in poll['options']) {
          options.add(opt['title']);
        }
        expiresIn = 86400;
      }
      vote = Vote.create(options, expiresIn,
          poll['multiple']);
    }

    if (info['scheduled_at'] != null)
    scheduledAt = DateTime.parse(info['scheduled_at']);
    sensitive = params['sensitive'];
    replyToId = params['in_reply_to_id'];
    counter = _controller.text.length;

    setState(() {});
  }

  bool get tootEdited {
    return (textEdited && _controller.text.isNotEmpty) ||
        medias.length > 0 ||
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



  Future<void> _pushNewToot() async {
    if (scheduledAt != null &&
        scheduledAt.difference(DateTime.now()).inSeconds < 300) {
      DialogUtils.toastErrorInfo('定时嘟文必须是五分钟后');
      return;
    }

    var mediaIds = [];

    if (medias.isNotEmpty) {
      var dialog = await DialogUtils.showProgressDialog('上传文件中...');
      dialog.show();
      for (PickedMedia media in medias) {
        if (media.remote != null) {
          var remoteId = media.remote.id;
          // fix hero
          if (remoteId.contains('##')) {
            remoteId = remoteId.substring(remoteId.lastIndexOf('##') + 2);
          }
          mediaIds.add(remoteId);
          continue;
        }
        String mediaId = await uploadMedia(media);
        if (mediaId == null) {
          dialog.hide();
          return;
        }
        mediaIds.add(mediaId);
      }
      dialog.hide();
    }

//    for (String file in images) {
//      var id = imageIds[file];
//      if (id != null) {
//        mediaIds.add(id);
//      }
//    }
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
          if (StatusItemData.fromJson(data).id == null) {
            throw Exception('push status failed');
          }
          _clearDraft();
          AppNavigate.pop();
          if (!data.containsKey('scheduled_at')) {
            SettingsProvider().homeProvider.addToListWithAnimation(data);
            if (data.containsKey('visibility') &&
                data['visibility'] == 'public' &&
                (data.containsKey('in_reply_to_id') &&
                        data['in_reply_to_id'] == null ||
                    data.containsKey('in_reply_to_account_id') &&
                        data['in_reply_to_account_id'] ==
                            LoginedUser().account.id)) {
              SettingsProvider().localProvider.addToListWithAnimation(data);
              SettingsProvider().federatedProvider.addToListWithAnimation(data);
            }
            StatusActionUtil.changeStatusCount(1);
          }
        }
      });
    } on DioError catch (e) {
      DialogUtils.toastErrorInfo('发送嘟嘟失败！');
    }
  }

  uploadMedia(PickedMedia media) async {
    File file = await media.local.file;
    if (!file.path.endsWith('.gif') && media.local.type == picker.AssetType.image) {
      file = await MediaUtil.compressImageFile(file);
    }
    if (file != null) {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
        "description" : media.description
      });
      var response;
      try {
        response =
            await Request.requestDio(url: Api.attachMedia, params: formData);
      } on DioError catch (e) {
        Fluttertoast.showToast(msg: '文件上传失败');
        return null;
      }
      String fileId = response['id'];
      return fileId;
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

  // Future chooseImage() async {
  //   var image = await MediaUtil.pickAndCompressImage();
  //
  //   if (image == null) {
  //     return;
  //   }
  //   if (images.length < 4) addImage(image);
  // }

  pickMedia(picker.RequestType type, int maxSize) async {
    final List<picker.AssetEntity> assets = await picker.AssetPicker.pickAssets(
        context,
        maxAssets: maxSize,
        themeColor: Colors.blue,
        previewThumbSize: const <int>[1200, 1200],
        requestType: type);
    if (assets == null) return;
    for (picker.AssetEntity entity in assets) {
      if (entity.type == picker.AssetType.video || entity.type == picker.AssetType.audio) {
        // file length will return 0
        var file = await entity.file;
        var fileLength = file.lengthSync();
        print(fileLength);
        if (fileLength > 40*1024*1024) {
          DialogUtils.toastFinishedInfo('文件大小必须小于40M');
          continue;
        }
      }
      medias.add(PickedMedia(local: entity));
    }
    setState(() {});
//    for (var media in assets) {
//      uploadMedia(media);
//    }
  }

  addImage(File file) {
    images.add(file.path);
    setState(() {});
  }

  removeImage(dynamic file) {
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
            onChanged: (value){
              setState(() {
                textEdited = true;
                counter = _controller.text.length + value.length > 500
                    ? 500
                    : _controller.text.length + value.length; //当500时可能值会变成501
              });
            },
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

  void showBottomSheetVisibility() {
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
                  leftIcon: Icon(
                    IconFont.earth,
                    size: 26,
                  ),
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
                  leftIcon: Icon(
                    IconFont.unlock,
                    size: 26,
                  ),
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
                  leftIcon: Icon(
                    IconFont.lock,
                    size: 26,
                  ),
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
                  leftIcon: Icon(
                    IconFont.message,
                    size: 26,
                  ),
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

  bool canPickMedia() {
    if (medias.isEmpty) {
      return true;
    }
    if (medias.length == 1) {
      PickedMedia media = medias[0];
      var localType = media?.local?.type;
      if (localType != null &&
          (localType == picker.AssetType.audio ||
              localType == picker.AssetType.video)) {
        return false;
      }
      var remoteType = media?.remote?.type;
      if (remoteType == 'gifv') {
        return true;
      }
      if (remoteType != null && remoteType != "image") {
        return false;
      }
    }
    if (medias.length < 4) {
      return true;
    } else {
      return false;
    }
  }

  void showBottomSheetMediaTypeOrPickImage() {
    if (medias.isNotEmpty) {
      pickMedia(picker.RequestType.image, 4 - medias.length);
      return;
    }
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                BottomSheetItem(
                  text: "选择照片",
                  onTap: () async => await pickMedia(
                      picker.RequestType.image, 4 - medias.length),
                ),
                Divider(
                  height: 0,
                ),
                BottomSheetItem(
                  text: "选择视频",
                  onTap: () async =>
                      await pickMedia(picker.RequestType.video, 1),
                ),
                Divider(
                  height: 0,
                ),
                BottomSheetItem(
                  text: "选择音频",
                  onTap: () async =>
                      await pickMedia(picker.RequestType.audio, 1),
                ),
                Container(
                  height: 8,
                  color: Theme.of(context).backgroundColor,
                ),
                BottomSheetCancelItem(),
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
    if (_controller.text.length == 0 && medias.length == 0) {
      return false;
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
            leading: InkWell(
              onTap: () => _onPressBack(),
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 15, 0, 0),
                child: Text(
                  '取消',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
            titleSpacing: 0,
            backgroundColor: Color.fromRGBO(appbarColor.red - 4,
                appbarColor.green - 4, appbarColor.blue - 4, 1),
            title: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                widget.replyTo == null ? '发嘟' : '回复',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                StringUtil.displayName(LoginedUser().account),
                style: TextStyle(
                    fontSize: 12, color: Theme.of(context).accentColor),
              )
            ]),
            centerTitle: true,
            actions: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(0, 8, 12, 6),
                child: ButtonTheme(
                  minWidth: 60,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: RaisedButton(
                    disabledTextColor: Colors.white.withOpacity(0.5),
                    disabledColor:
                        Theme.of(context).buttonColor.withOpacity(0.5),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      //   mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        warningWidget(),
                        StatusTextEditor(
                          controller: _controller,
                          focusNode: focusNode,
                          onChanged: (value) {
                            if (value.isEmpty) {
                              focusNode.requestFocus();
                            }
                            setState(() {
                              textEdited = true;
                              counter = value.length + _warningController.text.length > 500
                                  ? 500
                                  : value.length + _warningController.text.length; //当500时可能值会变成501
                            });
                          },
                        ),
                        if (vote != null)
                          SizedBox(
                            height: 20,
                          ),
                        if (vote != null) voteView(),
                        pickedMediaList(),
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
                            : canPickMedia()
                                ? showBottomSheetMediaTypeOrPickImage
                                : null,
                      ),
                      SizedIconButton(
                        onPressed: () {
                          showBottomSheetVisibility();
                        },
                        icon: _articleRange,
                      ),
                      if (medias.isNotEmpty)
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
                        onPressed: medias.length > 0
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
                        icon: Icon(
                          IconFont.cw,
                          color: _hasWarning
                              ? Theme.of(context).buttonColor
                              : null,
                        ),
//                            child: Text('cw',
//                                style: TextStyle(
//                                    fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                      SizedIconButton(
                        onPressed: () {
                          DatePicker.showDateTimePicker(context,
                              theme: DatePickerTheme(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  cancelStyle: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .color),
                                  itemStyle: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .color)),
                              showTitleActions: true,
                              minTime: DateTime.now().add(Duration(minutes: 8)),
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
                          color: scheduledAt != null ? Colors.blue : null,
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
                    child: EmojiKeyboard(onChoose: (e) {
                      setState(() {
                        var emoji = ' :' + e + ': ';
                        _controller.text = _controller.text.replaceRange(
                            cursorPositionWhenUnfocus,
                            cursorPositionWhenUnfocus,
                            emoji);
                        cursorPositionWhenUnfocus += emoji.length;
                        counter = _controller.text.length + _warningController.text.length;
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
      cursorPositionWhenUnfocus = _controller.selection.baseOffset;
      FocusScope.of(context).unfocus();
      if (kHeight != keyboardHeight) {
        setState(() {
          keyboardHeight = kHeight;
        });
      }
    } else {
      FocusScope.of(context).requestFocus(focusNode);
      SystemChannels.textInput.invokeMethod('TextInput.hide');
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
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: InkWell(
        key: btnKey,
        onTap: () => menu.show(widgetKey: btnKey),
        child: VoteDisplay(vote),
      ),
    );
  }

  Widget pickedMediaList() {
    return PickedMediaDisplay(
      medias,
      updateParentState: () {
        setState(() {});
      },
      onAddMediaClicked: () {
        pickMedia(picker.RequestType.image, 4 - medias.length);
      },
    );
  }
}
