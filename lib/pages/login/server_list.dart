import 'package:cached_network_image/cached_network_image.dart';
import 'package:dudu/public.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'model/server_item.dart';

class ServerList extends StatefulWidget {
  @override
  _ServerListState createState() => _ServerListState();
}

class _ServerListState extends State<ServerList>  {
  final String noticeString = '您只需选择一个节点即可进行注册。无论选择哪个节点，您都可以与任何人进行交流！';
  List _serverList = [];

  @override
  void initState() {
    super.initState();
    _getServerList();
  }

  Future<void> _getServerList() async {
    Map<String, dynamic> header = Map();
    header['Authorization'] = 'Bearer KxUopN7M0Vtkg2lTz2Svy01H5AfjGOAp4KzC2cKNFFJCrh4APAQauPQOC8Nr7ppR513cHYOfsAXg6l4gqnrTCEF9UxkHUNxRup2H7yVUAb2KAPYHmPsQDamBsXHylE4b';
    
    Request.get(url: Api.ServerList,header: header).then((data) {
      List allServer = data['instances'];
      if(this.mounted) {
        setState(() {
          _serverList = allServer;
        });
      }
    });
  }

  Widget _serverLogo(String url) {
    if(url == null) {
      return Image.asset('image/wallpaper.png', width: 70, height: 70);
    } else {
      return CachedNetworkImage(
        imageUrl: url,
        width: 70,
        height: 70,
      );
    }
  }

  Widget _rowBuild(BuildContext context, int index, ServerItem item) {
    String shortDes = '';
    if (item.info != null && item.info.shortDescription != null) {
      shortDes = item.info.shortDescription;
    }
    double users = int.parse(item.users) / 1000;
    List<String> userNum = users.toString().split(".");
    String showUsers = '';
    if (userNum[0] != '0') {
      showUsers = userNum[0] + 'K用户';
    } else {

      showUsers = int.parse(userNum[1]).toString() + '用户';
    }

    return GestureDetector(
      onTap: () {
        AppNavigate.pop(param: item);
      },
      child: Container(
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: _serverLogo(item.thumbnail),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(item.name, style: TextStyle(fontSize: 15),),
                  SizedBox(height: 5),
                  Text(shortDes, maxLines: 3, style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          color: Theme.of(context).buttonColor
                        ),
                      ),
                      SizedBox(width: 5),
                      Text('稳定', style: TextStyle(color: Theme.of(context).buttonColor)),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          color: Theme.of(context).buttonColor
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(showUsers, style: TextStyle(color: Theme.of(context).buttonColor))
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _loadingRequest(BuildContext context) {
    if(_serverList.length == 0) {
      return SpinKitThreeBounce(
        color: Theme.of(context).buttonColor,
        size: 50.0,
      );
    }
    return RefreshIndicator(
        onRefresh: () async => await _getServerList(),
        child: Column(
          children: <Widget>[
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Text(noticeString, style: TextStyle(fontSize: 12),), 
            ),
            Expanded(
              child: ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  ServerItem item = ServerItem.fromJson(_serverList[index]);
                  return _rowBuild(context, index, item);
                },
                itemCount: _serverList.length,
                separatorBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                    child: Divider(height: 1.0),
                  );
                },
              ),
            ),
          ],
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: CustomAppBar(
        title: Text('选择节点',),
        centerTitle: false,
        toolbarOpacity: 1,
        actions: <Widget>[

        ],
      ),
      body: _loadingRequest(context),
    );
  }
}

