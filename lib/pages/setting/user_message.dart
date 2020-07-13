import 'package:fastodon/api/accounts_api.dart';
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/pages/status/new_status.dart';
import 'package:fastodon/utils/dialog_util.dart';
import 'package:fastodon/widget/common/bottom_sheet_item.dart';
import 'package:fastodon/widget/common/colored_tab_bar.dart';
import 'package:fastodon/widget/common/measure_size.dart';
import 'package:fastodon/widget/listview/easyrefresh_listview.dart';
import 'package:fastodon/widget/listview/provider_easyrefresh_listview.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:fastodon/public.dart';
import 'package:fastodon/models/owner_account.dart';

import 'package:fastodon/widget/listview/refresh_load_listview.dart';
import 'package:fastodon/widget/status/status_item.dart';
import 'package:fastodon/models/article_item.dart';
import 'package:fastodon/models/my_account.dart';
import 'package:nav_router/nav_router.dart';
import 'package:provider/provider.dart';
import 'model/relation_ship.dart';
import 'package:fastodon/widget/other/avatar.dart';
import 'following_list.dart';
import 'follower_list.dart';

MyAccount mine = new MyAccount();

class UserMessage extends StatefulWidget {
  UserMessage({Key key, @required this.account}) : super(key: key);

  final OwnerAccount account;

  @override
  _UserMessageState createState() => _UserMessageState();
}

class _UserMessageState extends State<UserMessage>
    with SingleTickerProviderStateMixin {
  RelationShip relationShip;
  int _tabIndex = 0;


  OwnerAccount _account = mine.account;
  TabController _tabController;
  double _sliverExpandHeight = 10000;
  bool _getSliverExpandHeight = false;
  bool _showAccountInfoInAppBar = false;

  ScrollController _scrollController;
  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _tabController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _account = widget.account;
    if (mine.account.id != widget.account.id) {
      _getRelationShuips();
    }
    _tabController = TabController(length: 3, vsync: this);

    _scrollController = ScrollController()
      ..addListener(
            () {
              if (_scrollController.offset > _sliverExpandHeight - 200) {
                _setShowAccountInfo(true);
              } else {
                _setShowAccountInfo(false);
              }
            }
      );
  }



  Future<void> _getRelationShuips() async {
    Request.get(url: Api.Relationships, params: {'id[]': widget.account.id})
        .then((data) {
      List response = data;
      RelationShip relate = RelationShip.fromJson(response[0]);
      setState(() {
        relationShip = relate;
      });
    });
  }

  Future<void> _followByid() async {
    Map paramsMap = Map();
    paramsMap['reblogs'] = true;

    var data = await AccountsApi.follow(widget.account.id);
    if (data != null) {
      relationShip = RelationShip.fromJson(data);
      if (relationShip.following == true) {
        // 关注成功
        OwnerAccount mineAccount = mine.account;
        mineAccount.followingCount = mine.account.followingCount + 1;
        mine.setAcc(mineAccount);
      }
      setState(() {});
    }
  }

  Future<void> _unfollowByid() async {
    var data = await AccountsApi.unFollow(widget.account.id);
    if (data != null) {
      relationShip = RelationShip.fromJson(data);
      if (relationShip.following == false) {
        // 取关成功
        OwnerAccount mineAccount = mine.account;
        mineAccount.followingCount = mine.account.followingCount - 1;
        mine.setAcc(mineAccount);
      }
      setState(() {});
    }
  }

  Widget headerImage(BuildContext context) {
    if (widget.account == null) {
      return Container(
        height: 200,
      );
    }
    return Container(
      color: Theme.of(context).accentColor,
      child: CachedNetworkImage(
        height: 200,
        width: Screen.width(context),
        imageUrl: widget.account.header,
        fit: BoxFit.cover,
      ),
    );
  }

  _muteUser() async {
    var data = await AccountsApi.mute(widget.account.id);
    if (data != null) {
      setState(() {
        relationShip = RelationShip.fromJson(data);
      });
      eventBus.emit(EventBusKey.muteAccount, {'account_id': widget.account.id});
    }
  }

  _blockUser() async {
    var data = await AccountsApi.block(widget.account.id);
    if (data != null) {
      setState(() {
        relationShip = RelationShip.fromJson(data);
      });
      eventBus
          .emit(EventBusKey.blockAccount, {'account_id': widget.account.id});
    }
  }

  _unBlockUser() async {
    var data = await AccountsApi.unBlock(widget.account.id);
    if (data != null) {
      setState(() {
        relationShip = RelationShip.fromJson(data);
      });
    }
  }

  _onPressBlockButton() async {
    AppNavigate.pop(context);
    if (relationShip.blocking) {
      _unBlockUser();
    } else {
      DialogUtils.showSimpleAlertDialog(
          context: context,
          text: '确定要屏蔽@${widget.account.acct}吗',
          onConfirm: _blockUser);
    }
  }

  _onPressHideButton() async {
    AppNavigate.pop(context);
    if (relationShip.muting) {
      _onPressUnmute();
    } else {
      DialogUtils.showSimpleAlertDialog(
        context: context,
        text: '确定要隐藏@${widget.account.acct}吗',
        onConfirm: _muteUser,
      );
    }
  }

  _onPressUnmute() async {
    var data = await AccountsApi.unMute(widget.account.id);
    if (data != null) {
      setState(() {
        relationShip = RelationShip.fromJson(data);
      });
    }
  }

  _onPressBlockDomain() async {
    await AccountsApi.blockDomain(StringUtil.accountDomain(widget.account));
  }

  _onPressButton() async {
    if (relationShip.blocking) {
      _unBlockUser();
    } else if (relationShip.following) {
      _showUnfollowConfrimDialog();
    } else if (relationShip.requested) {
      // revoke request
      _unfollowByid();
    } else {
      _followByid();
    }
  }

  _showUnfollowConfrimDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('不再关注此用户'),
            actions: <Widget>[
              FlatButton(
                child: Text('取消'),
                onPressed: () => AppNavigate.pop(context),
              ),
              FlatButton(
                child: Text('确定'),
                onPressed: () {
                  AppNavigate.pop(context);
                  _unfollowByid();
                },
              )
            ],
          );
        });
  }

  _showMore() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return new Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              BottomSheetItem(
                  text: '提及',
                  onTap: () {
                    AppNavigate.pop(context);
                    AppNavigate.push(
                        context,
                        NewStatus(
                          prepareText: '@' + widget.account.acct + ' ',
                        ),
                        routeType: RouterType.material);
                  }),
              if (!relationShip.blocking && !relationShip.requested)
                BottomSheetItem(
                  text: relationShip.following ? '取消关注' : '关注',
                  onTap: _onPressButton,
                ),
              BottomSheetItem(
                text: relationShip.muting ? '取消隐藏' : '隐藏',
                onTap: _onPressHideButton,
              ),
              BottomSheetItem(
                text: relationShip.blocking ? '取消屏蔽' : '屏蔽',
                onTap: _onPressBlockButton,
              ),
              BottomSheetItem(
                text: '隐藏该用户所在域名',
                onTap: () => DialogUtils.showSimpleAlertDialog(
                    context: context,
                    text:
                        '你确定要屏蔽@${StringUtil.accountDomain(widget.account)}域名吗？你将不会在任何公共时间轴或通知中看到该域名的内容，而且该域名的关注者也会被删除',
                    onConfirm: _onPressBlockDomain,
                    popFirst: true),
              ),
              BottomSheetItem(
                text: '举报',
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

  Widget userHeader(BuildContext context) {
    return Container(
      child: MeasureSize(
        onChange: (size) {
          if (!_getSliverExpandHeight) {
            setState(() {
              _getSliverExpandHeight = true;
              _sliverExpandHeight = size.height + 20;
            });
            print(size.height);
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            headerImage(context),
            Stack(overflow: Overflow.visible, children: [
              Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Spacer(),
                        if (relationShip != null && relationShip.muting)
                          IconButton(
                            icon: Icon(Icons.volume_up),
                            onPressed: _onPressUnmute,
                          ),
                        Visibility(
                          visible: relationShip != null,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: RaisedButton(
                            child: Text(relationShip == null
                                ? 'whatever'
                                : relationShip.blocking
                                    ? '取消屏蔽'
                                    : relationShip.requested
                                        ? '已发送关注请求'
                                        : relationShip.following
                                            ? '取消关注'
                                            : '关注'),
                            onPressed: _onPressButton,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      StringUtil.displayName(widget.account),
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '@' + widget.account.acct,
                    ),
                    Container(
                        width: Screen.width(context) - 60,
                        child: Center(
                          child: Html(
                            data: widget.account.note,
                          ),
                        )),
                    headerFields(),
                    SizedBox(
                      height: 10,
                    ),
                    headerFollowsAndFollowers(),
                    SizedBox(
                      height: 10,
                    )
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
                      border: Border.all(width: 4, color: Colors.white),
                      borderRadius: new BorderRadius.all(Radius.circular(10.0)),
                      shape: BoxShape.rectangle,
                    ),
                    child: Avatar(
                      url: widget.account.avatar,
                    ),
                  )),
            ]),
            //   more(context),
          ],
        ),
      ),
    );
  }

  Widget headerFields() {
    List<Widget> rows = [];
    for (var filed in widget.account.fields) {
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            filed['name'],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Html(
            data: filed['value'],
            shrinkToFit: true,
          )
        ],
      ));
    }
    return Column(
      children: rows,
    );
  }

  Widget headerFollowsAndFollowers() {
    return DefaultTextStyle(
      style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Theme.of(context).accentColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          InkWell(
            child: Row(
              children: <Widget>[
                Text('关注'),
                SizedBox(
                  width: 5,
                ),
                Text(widget.account.followingCount.toString())
              ],
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Text('|'),
          SizedBox(
            width: 10,
          ),
          InkWell(
            child: Row(
              children: <Widget>[
                Text('粉丝'),
                SizedBox(
                  width: 5,
                ),
                Text(widget.account.followersCount.toString())
              ],
            ),
          )
        ],
      ),
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

  Widget row(int index, List data, ResultListProvider provider) {
    StatusItemData lineItem = StatusItemData.fromJson(data[index]);
    return StatusItem(item: lineItem);
  }

  Widget contentView() {
    return TabBarView(
      controller: _tabController,
  //    index: _tabIndex,
      children: <Widget>[
        ChangeNotifierProvider<ResultListProvider>(
          create: (context) => ResultListProvider(
              requestUrl:
                  Api.UersArticle(widget.account.id, 'exclude_replies=true'),
              buildRow: row,
              firstRefresh: true),
          child: ProviderEasyRefreshListView(),
        ),
        FollowingList(
          url: Api.Following(widget.account.id),
        ),
        FollowerList(
          url: Api.Follower(widget.account.id),
        ),
      ],
    );
  }

  _setShowAccountInfo(bool value) {
    if (value != _showAccountInfoInAppBar) {
      setState(() {
        _showAccountInfoInAppBar = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, boxIsScrolled) {
          return [
            SliverAppBar(
              title: _showAccountInfoInAppBar?Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(StringUtil.displayName(widget.account),style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                  Text('@'+widget.account.acct,style: TextStyle(fontSize: 14,fontWeight: FontWeight.normal),)
                ],
              ):Container(),
              centerTitle: false,
              pinned: true,
              floating: false,
              snap: false,
              //backgroundColor: Colors.transparent,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.more_horiz),
                  onPressed: _showMore,
                )
              ],
              flexibleSpace: !_getSliverExpandHeight
                  ? userHeader(context)
                  : FlexibleSpaceBar(
                  collapseMode:CollapseMode.pin,
                      background: userHeader(context),
                    ),
              expandedHeight: _sliverExpandHeight,
              bottom: ColoredTabBar(
                color: Theme.of(context).backgroundColor,
                tabBar: TabBar(
                  tabs: [
                    headerSection(context, _account.statusesCount, '嘟文'),
                    headerSection(context, _account.followingCount, '关注'),
                    headerSection(context, _account.followersCount, '粉丝'),
                  ],
                  onTap: (index) {
                    setState(() {
                      _tabIndex = index;
                    });
                  },
                  controller: _tabController,
                ),
              ),
            )
          ];
        },
        body: contentView(),
      ),
    );
  }
}
