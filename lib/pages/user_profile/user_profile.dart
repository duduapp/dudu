import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:dudu/api/accounts_api.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/models/json_serializable/media_attachment.dart';
import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/models/local_account.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/media/photo_gallery.dart';
import 'package:dudu/pages/setting/edit_user_profile.dart';
import 'package:dudu/pages/status/new_status.dart';
import 'package:dudu/pages/user_profile/user_follewers.dart';
import 'package:dudu/pages/user_profile/user_follewing.dart';
import 'package:dudu/pages/user_profile/user_report.dart';
import 'package:dudu/pages/webview/inner_browser.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/account_util.dart';
import 'package:dudu/utils/cache_manager.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/utils/view/list_view_util.dart';
import 'package:dudu/utils/view/status_action_util.dart';
import 'package:dudu/widget/common/bottom_sheet_item.dart';
import 'package:dudu/widget/common/colored_tab_bar.dart';
import 'package:dudu/widget/common/html_content.dart';
import 'package:dudu/widget/common/measure_size.dart';
import 'package:dudu/widget/listview/provider_easyrefresh_listview.dart';
import 'package:dudu/widget/other/avatar.dart';
import 'package:dudu/widget/status/text_with_emoji.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as extend;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';
import 'package:provider/provider.dart';

import '../setting/model/relation_ship.dart';

LoginedUser mine = LoginedUser();

class UserProfile extends StatefulWidget {
  UserProfile(this.account, {this.hostUrl, Key key}) : super(key: key);

  final OwnerAccount account;
  final String hostUrl;

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  RelationShip relationShip;

  OwnerAccount _account;
  TabController _tabController;
  double _sliverExpandHeight = 10000;
  bool _getSliverExpandHeight = false;
  bool _showAccountInfoInAppBar = false;
  List<ResultListProvider> providers = [];

  CancelToken cancelToken = CancelToken();

  ScrollController _scrollController;
  @override
  void dispose() {
    super.dispose();
    cancelToken.cancel('canceld');
    _scrollController.dispose();
    _tabController.dispose();
  }

  @override
  void initState() {
    super.initState();

    _onRefreshPage(firstRefresh: true);

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
        requestUrl: AccountsApi.statusUrl(
            account: widget.account,
            hostUrl: widget.hostUrl,
            param: 'exclude_replies=true'),
        buildRow: ListViewUtil.statusRowFunction(),
        dataHandler: ListViewUtil.dataHandlerPrefixIdFunction('status_'),
        enableRefresh: false,
      ),
      ResultListProvider(
          requestUrl: AccountsApi.statusUrl(
            account: widget.account,
            hostUrl: widget.hostUrl,
          ),
          buildRow: ListViewUtil.statusRowFunction(),
          dataHandler: ListViewUtil.dataHandlerPrefixIdFunction('replies_'),
          enableRefresh: false,
          firstRefresh: false),
      ResultListProvider(
        requestUrl: AccountsApi.statusUrl(
            account: widget.account,
            hostUrl: widget.hostUrl,
            param: 'pinned=true'),
        buildRow: ListViewUtil.statusRowFunction(),
        dataHandler: ListViewUtil.dataHandlerPrefixIdFunction('pinned_'),
        enableRefresh: false,
        firstRefresh: false,
      ),
      ResultListProvider(
          requestUrl: AccountsApi.statusUrl(
              account: widget.account,
              hostUrl: widget.hostUrl,
              param: 'only_media=true'),
          buildRow: _buildGridItem,
          enableRefresh: false,
          firstRefresh: false,
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

  Future<void> _followByid() async {
    Map paramsMap = Map();
    paramsMap['reblogs'] = true;
    if (widget.hostUrl != null) {
      _account = await StatusActionUtil.getAccountInLocal(null, _account);
    }
    var data = await AccountsApi.follow(_account.id);
    if (data != null) {
      relationShip = RelationShip.fromJson(data);
      if (relationShip.following == true) {
        // 关注成功
        OwnerAccount mineAccount = mine.account;
        mineAccount.followingCount = mine.account.followingCount + 1;
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
      }
      setState(() {});
    }
  }

  Widget headerImage(BuildContext context) {
    if (_account == null) {
      return Container(
        color: Theme.of(context).accentColor,
        height: 200,
      );
    }
    return Container(
      color: Theme.of(context).accentColor,
      child: CachedNetworkImage(
        height: 200,
        width: ScreenUtil.width(context),
        imageUrl: _account.header,
        fit: BoxFit.cover,
      ),
    );
  }

  _muteUser() async {
    if (widget.hostUrl != null) {
      _account = await StatusActionUtil.getAccountInLocal(null, _account);
    }
    var data = await AccountsApi.mute(_account.id);
    if (data != null) {
      setState(() {
        relationShip = RelationShip.fromJson(data);
      });
      ListViewUtil.removeStatusFromProvider(_account.id);
    }
  }

  _blockUser() async {
    if (widget.hostUrl != null) {
      _account = await StatusActionUtil.getAccountInLocal(null, _account);
    }
    var data = await AccountsApi.block(_account.id);
    if (data != null) {
      setState(() {
        relationShip = RelationShip.fromJson(data);
      });
      ListViewUtil.removeStatusFromProvider(_account.id);
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
    if (relationShip.blocking) {
      _unBlockUser();
    } else {
      DialogUtils.showSimpleAlertDialog(
          context: context,
          text: S.of(context).are_you_sure_to_block_users(_account.acct),
          onConfirm: _blockUser);
    }
  }

  _onPressHideButton() async {
    if (relationShip == null || !relationShip.muting) {
      DialogUtils.showSimpleAlertDialog(
        context: context,
        text: S.of(context).are_you_sure_to_hide_users(_account.acct),
        onConfirm: _muteUser,
      );
    } else {
      _onPressUnmute();
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
    if (mine.account.id == _account.id) {
      AppNavigate.push(EditUserProfile(_account));
    } else if (relationShip == null) {
      _followByid();
    } else if (relationShip.blocking) {
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
    DialogUtils.showSimpleAlertDialog(
        context: context,
        text: S.of(context).no_longer_follow_this_user,
        onConfirm: () {
          _unfollowByid();
        });
  }

  _showMore() async {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        builder: (BuildContext context) {
          return new Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (_account != null) ...[
                BottomSheetItem(
                    text: S.of(context).mention,
                    icon: IconFont.at,
                    onTap: () {
                      AppNavigate.push(
                          NewStatus(
                            prepareText: '@' + _account.acct + ' ',
                          ),
                          routeType: RouterType.material);
                    }),
                Divider(
                  indent: 60,
                  height: 0,
                )
              ],
              if (_isRemoteCachedAccount()) ...[
                BottomSheetItem(
                    text: S.of(context).open_in_browser,
                    icon: IconFont.earth,
                    onTap: () {
                      AppNavigate.push(InnerBrowser(widget.account.url));
                    }),
                Divider(
                  indent: 60,
                  height: 0,
                )
              ],
              if (_account != null && mine.account.id != _account.id) ...[
                if (relationShip == null ||
                    !relationShip.blocking && !relationShip.requested) ...[
                  BottomSheetItem(
                    icon: IconFont.follow,
                    text: relationShip == null || !relationShip.following
                        ? S.of(context).attention
                        : S.of(context).unsubscribe,
                    onTap: _onPressButton,
                  ),
                  Divider(
                    indent: 60,
                    height: 0,
                  )
                ],
                BottomSheetItem(
                  icon: IconFont.volumeOff,
                  text: relationShip == null || !relationShip.muting
                      ? S.of(context).hide
                      : S.of(context).unhide,
                  subText: S.of(context).hiding_description,
                  onTap: _onPressHideButton,
                ),
                Divider(
                  indent: 60,
                  height: 0,
                ),
                if (relationShip != null) ...[
                  BottomSheetItem(
                    icon: IconFont.report,
                    text: S.of(context).complaint,
                    onTap: () => AppNavigate.push(UserReport(
                      account: _account,
                    )),
                  ),
                  Divider(
                    indent: 60,
                    height: 0,
                  ),
                ],
                BottomSheetItem(
                  icon: IconFont.block,
                  text: relationShip == null || !relationShip.blocking
                      ? S.of(context).shield
                      : S.of(context).unblock,
                  subText: S.of(context).blocking_description,
                  onTap: _onPressBlockButton,
                ),
                Divider(
                  indent: 60,
                  height: 0,
                ),
                BottomSheetItem(
                  icon: IconFont.www,
                  text: S
                      .of(context)
                      .hide_instance(StringUtil.accountDomain(_account)),
                  subText: S.of(context).hiding_instance_description,
                  onTap: () => DialogUtils.showSimpleAlertDialog(
                      context: context,
                      text: S.of(context).hide_instance_confirm(
                          StringUtil.accountDomain(_account)),
                      onConfirm: _onPressBlockDomain,
                      popFirst: false),
                ),
                Divider(
                  indent: 60,
                  height: 0,
                ),
              ],
              Container(
                height: 8,
                color: Theme.of(context).backgroundColor,
              ),
              BottomSheetCancelItem()
            ],
          );
        });
  }

  _resetExpandHeight() {
    _getSliverExpandHeight = false;
    _sliverExpandHeight = 10000;
  }

  Widget userHeader(BuildContext context) {
    return Container(
      child: MeasureSize(
        onChange: (size) {
          if (!_getSliverExpandHeight) {
            setState(() {
              _getSliverExpandHeight = true;
              _sliverExpandHeight = size.height + 15;
            });
          }
        },
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              //  headerImage(context),
              Stack(overflow: Overflow.visible, children: [
                Column(
                  children: [
                    headerImage(context),
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
                                  icon: Icon(IconFont.volumeUp),
                                  onPressed: _onPressUnmute,
                                ),
                              Visibility(
                                visible: relationShip != null,
                                maintainSize: true,
                                maintainAnimation: true,
                                maintainState: true,
                                child: RaisedButton(
                                  textColor: Colors.white,
                                  child: Text(relationShip == null
                                      ? 'whatever'
                                      : mine.account.id == _account.id
                                          ? S.of(context).edit_information
                                          : relationShip.blocking
                                              ? S.of(context).unblock
                                              : relationShip.requested
                                                  ? S
                                                      .of(context)
                                                      .follow_request_sent
                                                  : relationShip.following
                                                      ? S
                                                          .of(context)
                                                          .unsubscribe
                                                      : S
                                                          .of(context)
                                                          .attention),
                                  onPressed: _onPressButton,
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          if (_account != null) ...[
                            TextWithEmoji(
                              text: StringUtil.displayName(_account),
                              emojis: _account.emojis,
                              style: TextStyle(
                                  //     fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .color,
                                  fontSize: 18),
                            ),
                            MediaQuery(
                              data: MediaQuery.of(context).copyWith(
                                  textScaleFactor: ScreenUtil.scaleFromSetting(
                                      SettingsProvider.getWithCurrentContext(
                                          'text_scale'))),
                              child: Row(
                                children: [
                                  Text(
                                    '@' + _account.acct,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Visibility(
                                    visible:
                                        _account != null && _account.locked,
                                    child: Icon(
                                      IconFont.lock,
                                      size: 16,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Visibility(
                              visible: relationShip != null &&
                                  relationShip.followedBy,
                              child: Container(
                                  padding: EdgeInsets.all(3),
                                  margin: EdgeInsets.only(top: 5),
                                  decoration: BoxDecoration(
                                      border: Border.all(),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Text(S.of(context).followed_you)),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                                width: ScreenUtil.width(context) - 60,
                                child: Center(
                                  child: HtmlContent(
                                    _account.note,
                                    emojis: _account.emojis,
                                    foldConetent: false,
                                  ),
                                )),
                            headerFields(),
                            SizedBox(
                              height: 10,
                            ),
                            if (_isRemoteCachedAccount())
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Text(
                                  S
                                      .of(context)
                                      .maybe_incomplete_user_information,
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor),
                                ),
                              ),
                            headerFollowsAndFollowers()
                          ],
                          SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                    )
                  ],
                ),
                Positioned(
                    top: 150,
                    left: 20,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => AppNavigate.push(
                          PhotoGallery(
                            galleryItems: [
                              MediaAttachment.fromJson({
                                'url': _account.avatar,
                                'preview_url': _account.avatar,
                                'id': 'user_avatar'
                              })
                            ],
                            initialIndex: 0,
                          ),
                          routeType: RouterType.fade),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(width: 4, color: Colors.white),
                          borderRadius:
                              new BorderRadius.all(Radius.circular(14.0)),
                          shape: BoxShape.rectangle,
                        ),
                        child: Hero(
                          tag: 'user_avatar',
                          child: Avatar(
                            width: 100,
                            height: 100,
                            navigateToDetail: false,
                            account: _account,
                          ),
                        ),
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
              child: HtmlContent(
                filed['name'],
                emojis: _account.emojis,
                //      shrinkToFit: true,
              )),
          Expanded(
            flex: 7,
            child: DefaultTextStyle.merge(
              style: TextStyle(color: Theme.of(context).accentColor),
              child: HtmlContent(
                filed['value'],
                emojis: _account.emojis,
                //      shrinkToFit: true,
              ),
            ),
          )
        ],
      ));
    }
    return Column(
      children: rows,
    );
  }

  _isRemoteCachedAccount() {
    if (!widget.account.url.startsWith(LoginedUser().host) &&
        widget.account.avatar.startsWith(LoginedUser().host)) {
      return true;
    }
    return false;
  }

  Widget headerFollowsAndFollowers() {
    return DefaultTextStyle(
      style: TextStyle(
          // fontWeight: FontWeight.bold,
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
                Text(S.of(context).toot),
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
            onTap: () async {
              if (widget.hostUrl != null) return null;
              AppNavigate.push(UserFollowing(_account.id));
            },
            child: Row(
              children: <Widget>[
                Text(_account.followingCount.toString()),
                SizedBox(
                  width: 1,
                ),
                Text(S.of(context).attention),
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
            onTap: () async {
              if (widget.hostUrl != null) return;
              AppNavigate.push(UserFollowers(_account.id));
            },
            child: Row(
              children: <Widget>[
                Text(_account.followersCount.toString()),
                SizedBox(
                  width: 1,
                ),
                Text(S.of(context).fans),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget tabText(String text) {
//    return Container(
//      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
//      child: Text(
//        text,
//        style: TextStyle(
//            fontSize: 18,
//            color: Theme.of(context).accentColor,
//            fontWeight: FontWeight.normal),
//      ),
//    );
    return Tab(
      text: text,
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
              child: ProviderEasyRefreshListView(
                firstRefresh: true,
              ),
            )),
        extend.NestedScrollViewInnerScrollPositionKeyWidget(
            Key('tab2'),
            ChangeNotifierProvider<ResultListProvider>.value(
              value: providers[2],
              child: ProviderEasyRefreshListView(
                firstRefresh: true,
              ),
            )),
        extend.NestedScrollViewInnerScrollPositionKeyWidget(
            Key('tab3'),
            ChangeNotifierProvider<ResultListProvider>.value(
              value: providers[3],
              child: Container(
                key: PageStorageKey('tab3'),
                child: ProviderEasyRefreshListView(
                  usingGrid: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  firstRefresh: true,
                ),
              ),
            )),
      ],
    );
  }

  _buildGridItem(int idx, List data, ResultListProvider provider) {
    MediaAttachment media = MediaAttachment.fromJson(data[idx]);
    return InkWell(
      onTap: () => AppNavigate.push(
          PhotoGallery(
            initialIndex: idx,
            galleryItems:
                provider.list.map((e) => MediaAttachment.fromJson(e)).toList(),
          ),
          routeType: RouterType.fade),
      child: Hero(
        tag: media.id,
        flightShuttleBuilder: (
          BuildContext flightContext,
          Animation<double> animation,
          HeroFlightDirection flightDirection,
          BuildContext fromHeroContext,
          BuildContext toHeroContext,
        ) {
          final Hero hero = flightDirection == HeroFlightDirection.push
              ? fromHeroContext.widget
              : toHeroContext.widget;
          return hero.child;
        },
        child: CachedNetworkImage(
            progressIndicatorBuilder: (context, widget, chunk) {
              return Container(
                color: Theme.of(context).accentColor,
              );
            },
            fit: BoxFit.cover,
            imageUrl: media.previewUrl,
            cacheManager: CustomCacheManager()),
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

  Future<void> _onRefreshPage({bool firstRefresh = false}) async {
    if (!firstRefresh) providers[_tabController.index]?.refresh();
    var newAccount = await AccountsApi.getAccount(widget.account,
        hostUrl: widget.hostUrl, cancelToken: cancelToken);
    if (newAccount != null &&
        newAccount.id == LoginedUser().account.id &&
        widget.hostUrl == null) {
      AccountUtil.updateAccount(newAccount);
    }
    var newRelationShip = await AccountsApi.getRelationShip(widget.account,
        hostUrl: widget.hostUrl, cancelToken: cancelToken);
    if (newAccount != null &&
        newRelationShip != null &&
        mounted) if (newAccount.acct == mine.account.acct) {
      mine.account = newAccount;
      LocalStorageAccount.addOwnerAccount(newAccount);
    }
    if (newAccount == null) {
      DialogUtils.showInfoDialog(
          context, S.of(context).failed_to_obtain_user_information);
    }
    setState(() {
      _account = newAccount ?? _account;
      relationShip = newRelationShip ?? relationShip;

      _resetExpandHeight();
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
                leading: InkWell(
                  onTap: () => AppNavigate.pop(),
                  child: Icon(IconFont.back),
                ),
                title: _showAccountInfoInAppBar
                    ? _account == null
                        ? Container()
                        : Container(
                            width: double.infinity,
                            color: Theme.of(context).appBarTheme.color,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  _account != null
                                      ? StringUtil.displayName(_account)
                                      : '',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '@' + _account.acct,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal),
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
                    icon: Icon(IconFont.moreHoriz),
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
                  color: Theme.of(context).appBarTheme.color,
                  tabBar: Align(
                    alignment: Alignment.centerLeft,
                    child: TabBar(
                      labelColor: Theme.of(context).buttonColor,
                      unselectedLabelColor: Theme.of(context).accentColor,
                      labelStyle: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.normal),
                      isScrollable: true,
                      indicatorColor: Theme.of(context).buttonColor,
                      tabs: [
                        tabText(S.of(context).toot),
                        tabText(S.of(context).toot_and_reply),
                        tabText(S.of(context).pinned),
                        tabText(S.of(context).media),
                      ],
                      onTap: (index) {
                        setState(() {});
                      },
                      controller: _tabController,
                    ),
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
