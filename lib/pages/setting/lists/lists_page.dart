import 'package:fastodon/api/lists_api.dart';
import 'package:fastodon/constant/api.dart';
import 'package:fastodon/pages/setting/lists/lists_eidt.dart';
import 'package:fastodon/pages/timeline/lists_timeline.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/utils/request.dart';
import 'package:fastodon/widget/common/loading_view.dart';
import 'package:flutter/material.dart';

class ListsPage extends StatefulWidget {
  @override
  _ListsPageState createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  List<dynamic> lists = [];

  bool loaded = false;

  @override
  void initState() {
    super.initState();
    _requestList();
  }

  _requestList() {
    Request.get(url: Api.lists).then((data) {
      setState(() {
        lists = data;
        loaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('列表'),
        centerTitle: false,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.add),onPressed: _showAddDialog,)
        ],
      ),
      body: loaded == true
          ? (lists.length == 0
              ? Text('没有内容')
              : Container(
                color: Theme.of(context).backgroundColor,
                child: ListView.builder(
                    itemCount: lists.length,
                    itemBuilder: _row,
                  ),
              ))
          : LoadingView(),
    );
  }

  Widget _row(BuildContext context, int idx) {
    return InkWell(
      onTap: ()=> AppNavigate.push(context, ListTimeline(lists[idx]['id'])),
      child: Container(
        padding: EdgeInsets.all(8),
        child: Row(children: [
          Icon(
            Icons.list,
            size: 25,
          ),
          Text(
            lists[idx]['title'],
            style: TextStyle(fontSize: 18),
          ),
          Spacer(),
          PopupMenuButton(
            offset: Offset(0, 35),
            icon: Icon(Icons.more_horiz),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              new PopupMenuItem<String>(value: 'edit', child: new Text('编辑列表')),
              new PopupMenuItem<String>(
                  value: 'rename', child: new Text('重命名列表')),
              new PopupMenuItem<String>(value: 'delete', child: new Text('删除列表')),
            ],
            onSelected: (String value) {
              switch (value) {
                case 'edit':
                  _showEditDialog(lists[idx]['id']);
                  break;
                case 'rename':
                  _showRenameDialog(lists[idx]['id'], lists[idx]['title']);
                  break;
                case 'delete':
                  _remove(lists[idx]['id']);
                  break;
              }
            },
          )
        ]),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
            border:
                Border(bottom: BorderSide(color: Theme.of(context).buttonColor))),
      ),
    );
  }

  _showEditDialog(String listId) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: ListsEdit(listId, ""),
          );
        });
  }

  _showRenameDialog(String id, String title) {
    TextEditingController _controller = TextEditingController(text: title);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: TextField(
              decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).buttonColor))
              ),
              controller: _controller,
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('取消'),
                onPressed: () => AppNavigate.pop(context),
              ),
              FlatButton(
                child: Text('重命名列表'),
                onPressed: () async {
                  await _rename(id, _controller.text.trim());
                  AppNavigate.pop(context);
                },
              )
            ],
          );
        });
  }

  _showAddDialog() {
    showDialog(context: context,builder: (BuildContext context) {
      TextEditingController _controller = TextEditingController();
      return AlertDialog(
        content: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: '列表名',
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).buttonColor))
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('取消'),
            onPressed: () => AppNavigate.pop(context),
          ),
          FlatButton(
            child: Text('新建列表'),
            onPressed: () async {
              _create(_controller.text.trim());
              AppNavigate.pop(context);
            },
          )
        ],
      );
    });
  }

  _rename(String id, String newTitle) async {
    await ListsApi.updateTitle(id, newTitle);
    _requestList();
  }

  _remove(String id) async {
    await ListsApi.remove(id);
    _requestList();
  }

  _create(String title) async{
    await ListsApi.add(title);
    _requestList();
  }
}
