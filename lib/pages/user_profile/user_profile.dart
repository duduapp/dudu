import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as extend;
import 'package:fastodon/api/accounts_api.dart';
import 'package:fastodon/models/media_attachment.dart';
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/pages/media/photo_gallery.dart';
import 'package:fastodon/pages/status/new_status.dart';
import 'package:fastodon/pages/user_profile/user_follewers.dart';
import 'package:fastodon/pages/user_profile/user_follewing.dart';
import 'package:fastodon/utils/dialog_util.dart';
import 'package:fastodon/utils/list_view.dart';
import 'package:fastodon/widget/common/bottom_sheet_item.dart';
import 'package:fastodon/widget/common/colored_tab_bar.dart';
import 'package:fastodon/widget/common/measure_size.dart';
import 'package:fastodon/widget/listview/provider_easyrefresh_listview.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:fastodon/public.dart';
import 'package:fastodon/models/owner_account.dart';

import 'package:fastodon/models/my_account.dart';
import 'package:nav_router/nav_router.dart';
import 'package:provider/provider.dart';
import '../setting/model/relation_ship.dart';
import 'package:fastodon/widget/other/avatar.dart';


MyAccount mine = new MyAccount();

class UserProfile extends StatefulWidget {
  UserProfile({Key key, @required this.account}) : super(key: key);

  final OwnerAccount account;

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  RelationShip relationShip;

  OwnerAccount _account = mine.account;
  TabController _tabController;
  double _sliverExpandHeight = 10000;
  bool _getSliverExpandHeight = false;
  bool _showAccountInfoInAppBar = false;
  List<ResultListProvider> providers = [];

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
    if (mine.account.id != _account.id) {
      _getRelationShuips();
    }
    _tabController = TabController(length: 4, vsync: this);

    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.offset > _sliverExpandHeight - 105) {
          _setShowAccountInfo(true);
        } else {
          _setShowAccountInfo(false);
        }
      });
    providers.addAll([
      ResultListProvider(
          requestUrl: Api.UersArticle(_account.id, 'exclude_replies=true'),
          buildRow: ListViewUtil.statusRowFunction(),
          firstRefresh: true,
          dataHandler: ListViewUtil.dataHandlerPrefixIdFunction('status_'),
          showHeader: false),
      ResultListProvider(
          requestUrl: AccountsApi.accountStatusUrl(_account.id),
          buildRow: ListViewUtil.statusRowFunction(),
          firstRefresh: true,
          dataHandler: ListViewUtil.dataHandlerPrefixIdFunction('replies_'),
          showHeader: false),
      ResultListProvider(
        requestUrl:
        AccountsApi.accountStatusUrl(_account.id, param: 'pinned=true'),
        buildRow: ListViewUtil.statusRowFunction(),
        firstRefresh: true,
        dataHandler: ListViewUtil.dataHandlerPrefixIdFunction('pinned_'),
        showHeader: false,
      ),
      ResultListProvider(
          requestUrl: AccountsApi.accountStatusUrl(_account.id,
              param: 'only_media=true'),
          buildRow: _buildGridItem,
          firstRefresh: true,
          showHeader: false,
          dataHandler: (data) {
            var handledData = [];
            for (var row in data) {
              row['media_attachments'].forEach((element) {
                element['id'] = 'media_' + element['id'];
              });
              handledData.addAll(row['media_attachments']);
            }
            return handledData;
          }),

    ]);
  }

  Future<void> _getRelationShuips() async {
    var res = await AccountsApi.getRelationShip(_account.id);
    setState(() {
      relationShip = res;
    });
  }

  Future<void> _followByid() async {
    Map paramsMap = Map();
    paramsMap['reblogs'] = true;

    var data = await AccountsApi.follow(_account.id);
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
    var data = await AccountsApi.unFollow(_account.id);
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
    if (_account == null) {
      return Container(
        height: 200,
      );
    }
    return Container(
      color: Theme.of(context).accentColor,
      child: CachedNetworkImage(
        height: 200,
        width: Screen.width(context),
        imageUrl: _account.header,
        fit: BoxFit.cover,
      ),
    );
  }

  _muteUser() async {
    var data = await AccountsApi.mute(_account.id);
    if (data != null) {
      setState(() {
        relationShip = RelationShip.fromJson(data);
      });
      eventBus.emit(EventBusKey.muteAccount, {'account_id': _account.id});
    }
  }

  _blockUser() async {
    var data = await AccountsApi.block(_account.id);
    if (data != null) {
      setState(() {
        relationShip = RelationShip.fromJson(data);
      });
      eventBus.emit(EventBusKey.blockAccount, {'account_id': _account.id});
    }
  }

  _unBlockUser() async {
    var data = await AccountsApi.unBlock(_account.id);
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
          text: '确定要屏蔽@${_account.acct}吗',
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
        text: '确定要隐藏@${_account.acct}吗',
        onConfirm: _muteUser,
      );
    }
  }

  _onPressUnmute() async {
    var data = await AccountsApi.unMute(_account.id);
    if (data != null) {
      setState(() {
        relationShip = RelationShip.fromJson(data);
      });
    }
  }

  _onPressBlockDomain() async {
    await AccountsApi.blockDomain(StringUtil.accountDomain(_account));
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
                          prepareText: '@' + _account.acct + ' ',
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
                        '你确定要屏蔽@${StringUtil.accountDomain(_account)}域名吗？你将不会在任何公共时间轴或通知中看到该域名的内容，而且该域名的关注者也会被删除',
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
              _sliverExpandHeight = size.height + 10;
            });
          }
        },
        child: SingleChildScrollView(
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
                        StringUtil.displayName(_account),
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '@' + _account.acct,
                      ),
                      Container(
                          width: Screen.width(context) - 60,
                          child: Center(
                            child: Html(
                              data: _account.note,
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
                        borderRadius:
                            new BorderRadius.all(Radius.circular(14.0)),
                        shape: BoxShape.rectangle,
                      ),
                      child: Avatar(
                        url: _account.avatar,
                      ),
                    )),
              ]),
              //   more(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget headerFields() {
    List<Widget> rows = [];
    for (var filed in _account.fields) {
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text(
              filed['name'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 7,
            child: Html(
              data: filed['value'],
              shrinkToFit: true,
            ),
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
            onTap: () => _tabController.animateTo(0),
            child: Row(
              children: <Widget>[
                Text(_account.statusesCount.toString()),
                SizedBox(
                  width: 1,
                ),
                Text('嘟文'),
              ],
            ),
          ),
          SizedBox(
            width: 10,
          ),
          //   Text('|'),
          SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () => AppNavigate.push(context, UserFollowing(_account.id)),
            child: Row(
              children: <Widget>[
                Text(_account.followingCount.toString()),
                SizedBox(
                  width: 1,
                ),
                Text('关注'),
              ],
            ),
          ),
          SizedBox(
            width: 10,
          ),
          //   Text('|'),
          SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () => AppNavigate.push(context, UserFollowers(_account.id)),
            child: Row(
              children: <Widget>[
                Text(_account.followersCount.toString()),
                SizedBox(
                  width: 1,
                ),
                Text('粉丝'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget tabText(String text) {
    return Tab(text: text,);
    return Container(
     padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, color: Theme.of(context).accentColor),
      ),
    );
  }

  Widget contentView() {
    return TabBarView(
      controller: _tabController,
      //    index: _tabIndex,
      children: <Widget>[
        extend.NestedScrollViewInnerScrollPositionKeyWidget(
            Key('tab0'),
            ChangeNotifierProvider<ResultListProvider>.value(
              value: providers[0],
              child: ProviderEasyRefreshListView(),
            )),
        extend.NestedScrollViewInnerScrollPositionKeyWidget(
            Key('tab1'),
            ChangeNotifierProvider<ResultListProvider>.value(
              value: providers[1],
              child: ProviderEasyRefreshListView(),
            )),
        extend.NestedScrollViewInnerScrollPositionKeyWidget(
            Key('tab2'),
            ChangeNotifierProvider<ResultListProvider>.value(
              value: providers[2],
              child: ProviderEasyRefreshListView(),
            )),
        extend.NestedScrollViewInnerScrollPositionKeyWidget(
            Key('tab3'),
            ChangeNotifierProvider<ResultListProvider>.value(
              value: providers[3],
              child: ProviderEasyRefreshListView(
                usingGrid: true,
              ),
            )),
      ],
    );
  }

  _buildGridItem(int idx, List data, ResultListProvider provider) {
    MediaAttachment media = MediaAttachment.fromJson(data[idx]);
    return InkWell(
      onTap: () => AppNavigate.push(
          context,
          PhotoGallery(
            initialIndex: idx,
            galleryItems:
                provider.list.map((e) => MediaAttachment.fromJson(e)).toList(),
          ),
          routeType: RouterType.fade),
      child: Hero(
        tag: media.id,
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: media.previewUrl,
        ),
      ),
    );
  }

  _setShowAccountInfo(bool value) {
    if (value != _showAccountInfoInAppBar) {
      setState(() {
        _showAccountInfoInAppBar = value;
      });
    }
  }

  Future<void> _onRefreshPage() async {
    providers[_tabController.index]?.refresh();
    var newAccount = await AccountsApi.getAccount(_account.id);
    var newRelationShip = await AccountsApi.getRelationShip(_account.id);
    setState(() {
      _account = newAccount ?? _account;
      relationShip = newRelationShip ?? relationShip;
      _getSliverExpandHeight = false;
      _sliverExpandHeight = 10000;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: extend.NestedScrollViewRefreshIndicator(
        onRefresh: _onRefreshPage,
        child: extend.NestedScrollView(
          innerScrollPositionKeyBuilder: () {
            return Key('tab${_tabController.index}');
          },
          controller: _scrollController,
          headerSliverBuilder: (context, boxIsScrolled) {
            return [
              SliverAppBar(

                titleSpacing: 0,
                title: _showAccountInfoInAppBar
                    ? Container(
                  width: double.infinity,
                  color: Theme.of(context).backgroundColor,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              StringUtil.displayName(_account),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '@' + _account.acct,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.normal),
                            )
                          ],
                        ),
                    )
                    : Container(),
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
                        collapseMode: CollapseMode.pin,
                        background: userHeader(context),
                      ),
                expandedHeight: _sliverExpandHeight,
                bottom: ColoredTabBar(
                  color: Theme.of(context).backgroundColor,
                  tabBar: TabBar(
                    tabs: [
                      tabText('嘟文'),
                      tabText('嘟文和回复'),
                      tabText('已置顶'),
                      tabText('媒体'),
                    ],
                    onTap: (index) {
                      setState(() {});
                    },
                    controller: _tabController,
                  ),
                ),
              )
            ];
          },
          body: contentView(),
        ),
      ),
    );
  }
}
