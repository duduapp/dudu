import 'package:cached_network_image/cached_network_image.dart';
import 'package:fastodon/constant/api.dart';
import 'package:fastodon/models/owner_account.dart';
import 'package:fastodon/utils/request.dart';
import 'package:flutter/material.dart';

class EditUserProfile extends StatefulWidget {
  final OwnerAccount account;
  EditUserProfile(this.account);

  @override
  _EditUserProfileState createState() => _EditUserProfileState();
}

class _EditUserProfileState extends State<EditUserProfile> {
  OwnerAccount account;

  TextEditingController usernameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  List<List<TextEditingController>> extraInfoControllers = [[TextEditingController(),TextEditingController()]];

  bool locked;

  initState() {
    super.initState();
    account = widget.account;
    locked = account.locked;
  }

  Future<void> _getMyAccount() async {
    Request.get(url: Api.OwnerAccount).then((data) {
      OwnerAccount account = OwnerAccount.fromJson(data);
      setState(() {
        this.account = account;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context).toggleableActiveColor;
    return Scaffold(
      appBar: AppBar(
        title: Text('编辑个人资料'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.check),)
        ],
      ),
      body:SingleChildScrollView(
        child: Theme(
          data: ThemeData(primaryColor: color),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  color: Colors.grey,
                  height: 200,
                  child: Stack(
                    children: <Widget>[
                      if(widget.account.header != null)
                        CachedNetworkImage(imageUrl: widget.account.header,),
                      Positioned.fill(child: Center(child: IconButton(icon: Icon(Icons.camera_alt,size: 50,color: Colors.white,),)))
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(12),
                  child: Stack(overflow:Overflow.visible,children: <Widget>[
                    Column(
                      children: <Widget>[
                        SizedBox(height: 30,),
                        TextField(
                          decoration: InputDecoration(hintText: '昵称'),
                        ),
                        TextField(
                          decoration: InputDecoration(hintText: '简介'),
                        ),
                      ],
                    ),
                    Positioned(
                      top: -50,
                      child: Stack(
                        children: <Widget>[
                          ClipRRect(child: CachedNetworkImage(imageUrl: account.avatar,width: 80,height: 80,),borderRadius: BorderRadius.circular(5),),
                          Positioned.fill(child: Center(child: IconButton(icon: Icon(Icons.camera_alt,size: 30,color: Colors.white,),)))
                        ],
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
      children.add(TextField(controller: extraInfoControllers[i][0],decoration: InputDecoration(hintText: '标签'),));
      children.add(TextField(controller: extraInfoControllers[i][1],decoration: InputDecoration(hintText: '内容'),));
      children.add(SizedBox(height: 10,));
    }
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(children: children),
    );
  }
}
