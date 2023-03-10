import 'package:dudu/l10n/l10n.dart';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:dudu/api/accounts_api.dart';
import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/utils/media_util.dart';
import 'package:dudu/widget/common/bottom_sheet_item.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditUserProfile extends StatefulWidget {
  final OwnerAccount account;
  final bool showBottomChooseImage;
  EditUserProfile(this.account, {this.showBottomChooseImage = false});

  @override
  _EditUserProfileState createState() => _EditUserProfileState();
}

class _EditUserProfileState extends State<EditUserProfile> {
  OwnerAccount account;
  String header;
  String avatar;
  bool locked;
  bool isUpdating = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  List<List<TextEditingController>> extraInfoControllers = [];

  initState() {
    super.initState();
    account = widget.account;
    locked = account.locked;
    header = account.header;
    avatar = account.avatar;

    nameController.text = account.displayName;
    noteController.text = StringUtil.removeAllHtmlTags(account.note);

    for (Map filed in account.fields) {
      extraInfoControllers.add([
        TextEditingController(text: filed['name']),
        TextEditingController(text: filed['value'])
      ]);
    }
    if (extraInfoControllers.length == 0) {
      extraInfoControllers
          .add([TextEditingController(), TextEditingController()]);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showBottomChooseImage) {
        showSheet(context);
      }
    });
  }

  Widget headerView() {
    if (Uri.parse(header).isAbsolute) {
      return CachedNetworkImage(
        imageUrl: header,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } else {
      return Image.file(
        File(header),
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }
  }

  Widget avatarView() {
    if (Uri.parse(avatar).isAbsolute) {
      return CachedNetworkImage(
        imageUrl: account.avatar,
        width: 80,
        height: 80,
        fit: BoxFit.fitWidth,
      );
    } else {
      return Image.file(
        File(avatar),
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      );
    }
  }

  chooseHeader() async {
    var image = await MediaUtil.pickAndCompressImage(context);
    if (image == null) {
      return;
    }

    setState(() {
      header = image.path;
    });
    debugPrint(image.toString());
  }

  chooseAvatar() async {
    var image = await MediaUtil.pickAndCompressImage(context);
    if (image == null) {
      return;
    }
    setState(() {
      avatar = image.path;
    });
    debugPrint(image.toString());
  }

  _save() async {
    setState(() {
      isUpdating = true;
    });
    Map<String, dynamic> params = {};
    if (!StringUtil.isUrl(header)) {
      params['header'] = MultipartFile.fromFileSync(header);
    }
    if (!StringUtil.isUrl(avatar)) {
      params['avatar'] = MultipartFile.fromFileSync(avatar);
    }
    params['display_name'] = nameController.text;
    params['note'] = noteController.text;

    params['locked'] = locked;
    params['fields_attributes'] = _getFileds();
    try {
      var res = await AccountsApi.updateCredentials(params);
    if (res != null) {

      SettingsProvider().updateCurrentAccount(OwnerAccount.fromJson(res));
    }
    } catch (e) {
      setState(() {
        isUpdating = false;
      });
      DialogUtils.showInfoDialog(context, e.response.toString());
      return;
    }
   // eventBus.emit(EventBusKey.accountUpdated);
    AppNavigate.pop();
  }

  List _getFileds() {
    List<Map> filedAttrs = [];
    for (int i = 0; i < extraInfoControllers.length; i++) {
      filedAttrs.add({
        'name': extraInfoControllers[i][0].text,
        'value': extraInfoControllers[i][1].text
      });
    }
    return filedAttrs;
  }

  showSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (_) => Container(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  BottomSheetItem(
                    text: S.of(context).modify_picture_background,
                    onTap: chooseHeader,
                  ),
                  Container(
                    height: 1,
                    color: Theme.of(context).backgroundColor,
                  ),
                  BottomSheetItem(
                    text: S.of(context).modify_avatar,
                    onTap: chooseAvatar,
                  ),
                  Container(
                    height: 8,
                    color: Theme.of(context).backgroundColor,
                  ),
                  BottomSheetCancelItem()
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context).toggleableActiveColor;
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(S.of(context).edit_profile,style: TextStyle(fontSize: 16),),
        actions: <Widget>[
          isUpdating
              ? Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: CupertinoActivityIndicator(),
                )
              : InkWell(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(right: 15, top: 12, left: 15),
                    child: Text(
                      S.of(context).determine,
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).buttonColor),
                    ),
                  ),
                  onTap: _save,
                )
        ],
      ),
      body: SingleChildScrollView(
        child: Theme(
          data: Theme.of(context)
              .copyWith(primaryColor: Theme.of(context).buttonColor),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  onTap: () => showSheet(context),
                  child: Container(
                    width: double.infinity,
                    color: Theme.of(context).accentColor,
                    height: 200,
                    child: Stack(
                      children: <Widget>[
                        Builder(builder: (context) => headerView()),
                        //   Positioned.fill(child: Center(child: IconButton(icon: Icon(Icons.camera_alt,size: 35,color: Colors.white,),onPressed: showSheet(context),)))
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(12),
                  child: Stack(
                    overflow: Overflow.visible,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          SizedBox(
                            height: 50,
                          ),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                                hintText: S.of(context).nickname,
                                labelText: S.of(context).nickname,
                                helperText: '',
                                counterText: '',
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .color)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).buttonColor))),
                            maxLength: 30,
                          ),
                          TextField(
                            controller: noteController,
                            decoration: InputDecoration(
                                hintText: S.of(context).introduction,
                                labelText: S.of(context).introduction,
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .color)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).buttonColor))),
                            maxLength: 500,
                            maxLines: null,
                          ),
                        ],
                      ),
                      Positioned(
                        top: -50,
                        child: InkWell(
                          onTap: () => showSheet(context),
                          child: ClipRRect(
                            child: avatarView(),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: locked,
                      onChanged: _onLockChanged,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            S.of(context).protect_your_account,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(S.of(context).you_need_to_manually_review_all_follow_requests)
                        ],
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
                  child: Text(
                    S.of(context).profile_additional_information,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                extraWidgets(),
                Padding(
                  padding: const EdgeInsets.only(right: 12, bottom: 30),
                  child: Align(
                    child: RaisedButton(
                      child: Text(S.of(context).add_information),
                      onPressed: _addExtra,
                    ),
                    alignment: Alignment.bottomRight,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _onLockChanged(bool change) {
    setState(() {
      locked = change;
    });
  }

  _addExtra() {
    if (extraInfoControllers.length < 4) {
      setState(() {
        extraInfoControllers
            .add([TextEditingController(), TextEditingController()]);
      });
    }
  }

  Widget extraWidgets() {
    List<Widget> children = [];
    for (int i = 0; i < extraInfoControllers.length; i++) {
      children.add(TextField(
        controller: extraInfoControllers[i][0],
        decoration: InputDecoration(hintText: S.of(context).label, counterText: ''),
        maxLength: 255,
        maxLines: null,
      ));
      children.add(TextField(
        controller: extraInfoControllers[i][1],
        decoration: InputDecoration(hintText: S.of(context).content, counterText: ''),
        maxLength: 255,
        maxLines: null,
      ));
      children.add(SizedBox(
        height: 10,
      ));
    }
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(children: children),
    );
  }
}
