import 'package:fastodon/widget/common/bottom_sheet_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:fastodon/public.dart';
import 'package:fastodon/models/owner_account.dart';

import 'package:fastodon/widget/listview/refresh_load_listview.dart';
import 'package:fastodon/widget/status/status_item.dart';
import 'package:fastodon/models/article_item.dart';
import 'package:fastodon/models/my_account.dart';
import 'model/relation_ship.dart';
import 'package:fastodon/widget/other/avatar.dart';
import 'following_list.dart';
import 'follower_list.dart';
import 'user_sheet_cell.dart';

MyAccount mine = new MyAccount();

class UserMessage extends StatefulWidget {
  UserMessage({Key key, @required this.account}) : super(key: key);

  final OwnerAccount account;

  @override
  _UserMessageState createState() => _UserMessageState();
}

class _UserMessageState extends State<UserMessage> {
  int _currentWidget = 0;
  bool followed;
  String _bottomSheetTitle = '未关注';
  String _bottomSheetFunName = '关注';
  OwnerAccount _account = mine.account;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _account = widget.account;
    if (mine.account.id != widget.account.id) {
      _getRelationShuips();
    }
  }

  void _changeBottomSheet(RelationShip relate) {
    String title = '';
    String name = '';


      setState(() {
        followed = relate.following;
      });


    if (relate.followedBy == true && relate.following == true) {
      title = '互相关注';
      name = '取消关注';
    } else if (relate.followedBy == false && relate.following == true) {
      title = '已关注';
      name = '取消关注';
    } else if (relate.followedBy == true && relate.following == false) {
      title = '我的粉丝';
      name = '关注';
    } else if (relate.followedBy == false && relate.following == false) {
      title = '未关注';
      name = '关注';
    }
    setState(() {
      _bottomSheetTitle = title;
      _bottomSheetFunName = name;
    });
  }

  Future<void> _getRelationShuips() async {
    Request.get(url: Api.Relationships, params: {'id[]': widget.account.id})
        .then((data) {
      List response = data;
      RelationShip relate = RelationShip.fromJson(response[0]);
      _changeBottomSheet(relate);
    });
  }

  Future<void> _followByid() async {
    Map paramsMap = Map();
    paramsMap['reblogs'] = true;

    Request.post(url: Api.Follow(widget.account.id), params: paramsMap)
        .then((data) {
      RelationShip relate = RelationShip.fromJson(data);
      if (relate.following == true) {
        setState(() {
          followed  = true;
        });
        // 关注成功
        OwnerAccount mineAccount = mine.account;
        mineAccount.followingCount = mine.account.followingCount + 1;
        mine.setAcc(mineAccount);
      }
      _changeBottomSheet(relate);
    });
  }

  Future<void> _unfollowByid() async {
    Request.post(url: Api.UnFollow(widget.account.id)).then((data) {
      RelationShip relate = RelationShip.fromJson(data);
      if (relate.following == false) {
        setState(() {
          followed = false;
        });
        // 取关成功
        OwnerAccount mineAccount = mine.account;
        mineAccount.followingCount = mine.account.followingCount - 1;
        mine.setAcc(mineAccount);
      }
      _changeBottomSheet(relate);
    });
  }

  Widget header(BuildContext context) {
    if (widget.account == null) {
      return Container(
        height: 200,
      );
    }
    return Container(
      child: CachedNetworkImage(
        height: 200,
        width: Screen.width(context),
        imageUrl: widget.account.header,
        fit: BoxFit.cover,
      ),
    );
  }


  _showMore() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return new Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Center(
                  child: Text(_bottomSheetTitle,
                      style: TextStyle(
                          fontSize: 13, color: MyColor.greyText)),
                ),
              ),
              BottomSheetItem(
                text: '提及',
              ),
              BottomSheetItem(
                text: '私信',
              ),
              BottomSheetItem(
                text: '隐藏',
              ),
              BottomSheetItem(
                text: '屏蔽',
              ),
              BottomSheetItem(
                text: '举报',
              ),
              BottomSheetItem(
                text: _bottomSheetFunName,
                onTap: () {
                  if (_bottomSheetFunName == '关注') {
                    _followByid();
                  }
                  if (_bottomSheetFunName == '取消关注') {
                    _unfollowByid();
                  }
                },
              ),
          Container(
          height: 8,
          color: Theme.of(context).backgroundColor,
          ),
          BottomSheetItem(
                text: '取消',
                onTap: () => AppNavigate.pop(context),
                safeArea: true,
              )
            ],
          );
        });
  }

  _onPressFollow() {
    if (followed) {
      _showUnfollowConfrimDialog();
    } else {
      _followByid();
    }
  }

  _showUnfollowConfrimDialog() {
    showDialog(context: context,builder: (BuildContext context) {
      return AlertDialog(
        content: Text('不再关注此用户'),
        actions: <Widget>[
          FlatButton(child: Text('取消'),onPressed: () => AppNavigate.pop(context),),
          FlatButton(child: Text('确定'),onPressed: () {_unfollowByid();AppNavigate.pop(context);},)
        ],
      );
    });
  }

  Widget userHeader(BuildContext context) {
    return Column(
      children: <Widget>[
        header(context),
        Stack(overflow: Overflow.visible, children: [
          Container(
            padding: EdgeInsets.only(left: 20,right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 10),
                Row(children: <Widget>[
                  Spacer(),
                  if (followed != null)
                  RaisedButton(child: Text(followed ?'取消关注': '关注'),onPressed: _onPressFollow,)
                ],),
                SizedBox(height: 20,),
                Text(
                  StringUtil.displayName(widget.account),
                  style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                ),
                Text(
                  '@'+widget.account.acct,
                ),
                Container(
                    width: Screen.width(context) - 60,
                    child: Center(
                      child: Html(
                          data: widget.account.note,),
                    )),
                headerFields()
              ],
            ),
          ),
          Positioned(
              top: -50,
              left: 20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(width: 4,color: Colors.white),
                  borderRadius: new BorderRadius.all(Radius.circular(10.0)),
                  shape: BoxShape.rectangle,
                ),
                child: Avatar(url: widget.account.avatar,),
              )),
        ]),
        //   more(context),
      ],
    );
  }

  Widget headerFields() {
    List<Widget> rows = [];
    for (var filed in widget.account.fields) {
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(filed['name'],style: TextStyle(fontWeight: FontWeight.bold),),
          Text(filed['value'])
        ],
      ));
    }
    return Column(
      children: rows,
    );
  }

  Widget headerSection(BuildContext context, int number, String title) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Column(
        children: <Widget>[
          Text('$number',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          Text(title, style: TextStyle(fontSize: 13, color: MyColor.greyText))
        ],
      ),
    );
  }

  Widget row(int index, List data) {
    StatusItemData lineItem = StatusItemData.fromJson(data[index]);
    return StatusItem(item: lineItem);
  }

  Widget contentView(int index) {
    switch (index) {
      case 0:
        return RefreshLoadListView(
          requestUrl:
              Api.UersArticle(widget.account.id, 'exclude_replies=true'),
          buildRow: row,
        );
        break;
      case 1:
        return FollowingList(
          url: Api.Following(widget.account.id),
        );
        break;
      case 2:
        return FollowerList(
          url: Api.Follower(widget.account.id),
        );
        break;
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.more_horiz),onPressed: _showMore,)
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: <Widget>[
          userHeader(context),
          DefaultTabController(
              length: 3,
              child: Container(
                color: Colors.white,
                child: TabBar(
                  tabs: [
                    headerSection(context, _account.statusesCount, '嘟文'),
                    headerSection(context, _account.followingCount, '关注'),
                    headerSection(context, _account.followersCount, '粉丝'),
                  ],
                  onTap: (index) {
                    setState(() {
                      _currentWidget = index;
                    });
                  },
                ),
              )),
          Expanded(
            child: contentView(_currentWidget),
          ),
        ],
      ),
    );
  }
}
