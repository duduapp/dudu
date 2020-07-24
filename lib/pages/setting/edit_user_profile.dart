import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:fastodon/api/accounts_api.dart';
import 'package:fastodon/constant/api.dart';
import 'package:fastodon/models/json_serializable/owner_account.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/utils/dialog_util.dart';
import 'package:fastodon/utils/media_util.dart';
import 'package:fastodon/utils/request.dart';
import 'package:fastodon/widget/common/bottom_sheet_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditUserProfile extends StatefulWidget {
  final OwnerAccount account;
  EditUserProfile(this.account);

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
      extraInfoControllers.add([TextEditingController(text: filed['name']),TextEditingController(text: filed['value'])]);
    }
    if (extraInfoControllers.length == 0) {
      extraInfoControllers.add([TextEditingController(),TextEditingController()]);
    }
    
  }

  Future<void> _getMyAccount() async {
    Request.get(url: Api.OwnerAccount).then((data) {
      OwnerAccount account = OwnerAccount.fromJson(data);
      setState(() {
        this.account = account;
      });
    });
  }

  Widget headerView() {
    if (Uri.parse(header).isAbsolute) {
      return CachedNetworkImage(imageUrl: header,fit: BoxFit.cover,width: double.infinity,);
    } else {
      return Image.file(File(header),fit: BoxFit.cover,width: double.infinity,);
    }
  }

  Widget avatarView() {
    if (Uri.parse(avatar).isAbsolute) {
      return CachedNetworkImage(imageUrl: account.avatar,width: 80,height: 80,fit: BoxFit.fitWidth,);
    } else {
      return Image.file(File(avatar),width: 80,height: 80,fit: BoxFit.cover,);
    }
  }

  chooseHeader() async{
      AppNavigate.pop(context);
      var image = await MediaUtil.pickAndCompressImage();
      if (image == null) {
        return;
      }

      setState(() {
        header = image.path;
      });
      print(image);
  }

  chooseAvatar() async {
    AppNavigate.pop(context);
    var image = await MediaUtil.pickAndCompressImage();
    if (image == null) {
      return;
    }
    setState(() {
      avatar = image.path;
    });
    print(image);
  }

  _save() async{
    setState(() {
      isUpdating = true;
    });
    Map<String,dynamic> params = {};
    if (!StringUtil.isUrl(header)) {
      params['header'] = MultipartFile.fromFileSync(header);
    }
    if (!StringUtil.isUrl(avatar)) {
      params['avatar'] = MultipartFile.fromFileSync(avatar);
    }
    if (nameController.text.isNotEmpty)
    params['display_name'] = nameController.text;
    if (noteController.text.isNotEmpty)
    params['note'] = noteController.text;

    params['locked'] = locked;
    params['fields_attributes'] = _getFileds();
    try {
      await AccountsApi.updateCredentials(params);
    } catch (e) {
      setState(() {
        isUpdating = false;
      });
      DialogUtils.showInfoDialog(context, e.response.toString());
      return;
    }
    eventBus.emit(EventBusKey.accountUpdated);
    AppNavigate.pop(context);
  }


  List _getFileds() {
    List<Map> filedAttrs = [];
    for (int i = 0; i < extraInfoControllers.length; i++) {
      filedAttrs.add(
          {
            'name':extraInfoControllers[i][0].text,
            'value' :extraInfoControllers[i][1].text
          }
      );
    }
    return filedAttrs;
  }

  showSheet(BuildContext context) {
    showModalBottomSheet(context: context, builder: (_) => Container(
      width: double.infinity,


      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          BottomSheetItem(text: '修改图片背景',onTap: chooseHeader,),
          Container(height: 1,color: Theme.of(context).backgroundColor,),
          BottomSheetItem(text: '修改头像',onTap: chooseAvatar,),

          Container(height: 8,color: Theme.of(context).backgroundColor,),

          BottomSheetItem(text: '取消',onTap: () => AppNavigate.pop(context),height: Screen.bottomSafeHeight(context) + 26,)


        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context).toggleableActiveColor;
    return Scaffold(
      appBar: AppBar(
        title: Text('编辑个人资料'),
        actions: <Widget>[
          isUpdating?  Padding(
            padding: const EdgeInsets.only(right: 15),
            child: CupertinoActivityIndicator(),
          ):IconButton(icon: Icon(Icons.check),onPressed: _save,)
        ],
      ),
      body:SingleChildScrollView(
        child: Theme(
          data: Theme.of(context).copyWith(primaryColor: Colors.black),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  onTap: () =>showSheet(context),
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey,
                    height: 200,
                    child: Stack(
                      children: <Widget>[
                        Builder(builder:(context) =>headerView()),
                     //   Positioned.fill(child: Center(child: IconButton(icon: Icon(Icons.camera_alt,size: 35,color: Colors.white,),onPressed: showSheet(context),)))
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(12),
                  child: Stack(overflow:Overflow.visible,children: <Widget>[
                    Column(
                      children: <Widget>[
                        SizedBox(height: 50,),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(hintText: '昵称',labelText: '昵称',helperText: '',counterText: '',enabledBorder: OutlineInputBorder(
                          ),focusedBorder: OutlineInputBorder()),
                          maxLength: 30,
                        ),
                        TextField(
                          controller: noteController,
                          decoration: InputDecoration(hintText: '简介',labelText: '简介',enabledBorder: OutlineInputBorder(),focusedBorder: OutlineInputBorder()),
                          maxLength: 500,
                          maxLines: null,
                        ),
                      ],
                    ),
                    Positioned(
                      top: -50,
                      child: InkWell(
                        onTap: () => showSheet(context),
                        child: ClipRRect(child: avatarView(),borderRadius: BorderRadius.circular(5),),
                      ),
                    )
                  ],),
                ),
                Row(
                  children: <Widget>[
                    Checkbox(value: locked,onChanged: _onLockChanged,),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                        Text('保护你的账户（锁嘟）',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                        Text('你需要手动审核所有关注请求')
                      ],),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB( 12,20,12,0),
                  child: Text('个人资料附加信息',style: TextStyle(color: Colors.grey),),
                ),

                extraWidgets(),

                Padding(
                  padding: const EdgeInsets.only(right: 12,bottom: 30),
                  child: Align(child: RaisedButton(child: Text('添加信息'),onPressed: _addExtra,),alignment: Alignment.bottomRight,),
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
        extraInfoControllers.add([TextEditingController(),TextEditingController()]);
      });
    }
  }

  Widget extraWidgets() {
    List<Widget> children = [];
    for (int i = 0; i < extraInfoControllers.length; i++) {
      children.add(TextField(controller: extraInfoControllers[i][0],decoration: InputDecoration(hintText: '标签',counterText: ''),maxLength: 255,maxLines: null,));
      children.add(TextField(controller: extraInfoControllers[i][1],decoration: InputDecoration(hintText: '内容',counterText: ''),maxLength: 255,maxLines: null,));
      children.add(SizedBox(height: 10,));
    }
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(children: children),
    );
  }
}
