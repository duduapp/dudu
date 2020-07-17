import 'package:fastodon/api/lists_api.dart';
import 'package:fastodon/constant/api.dart';
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/pages/setting/lists/lists_eidt.dart';
import 'package:fastodon/pages/timeline/lists_timeline.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/widget/common/list_row.dart';
import 'package:fastodon/widget/listview/provider_easyrefresh_listview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListsPage extends StatefulWidget {
  @override
  _ListsPageState createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  BuildContext providerContext;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('列表'),
        centerTitle: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddDialog(),
          )
        ],
      ),
      body: ChangeNotifierProvider<ResultListProvider>(
          create: (context) => ResultListProvider(
              requestUrl: Api.lists,
              buildRow: _row,
              enableRefresh: false,
              reverseData: true),
          builder: (context, snapshot) {
            providerContext = context;
            return ProviderEasyRefreshListView();
          }),
    );
  }

  Widget _row(int idx, List data,ResultListProvider provider) {
    var list = data[idx];
    return ListRow(
      child: InkWell(
        onTap: () => AppNavigate.push(context, ListTimeline(list['id'])),
        child: Row(children: [
          Icon(
            Icons.list,
            size: 25,
          ),
          Text(
            list['title'],
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
              new PopupMenuItem<String>(
                  value: 'delete', child: new Text('删除列表')),
            ],
            onSelected: (String value) {
              switch (value) {
                case 'edit':
                  _showEditDialog(list['id']);
                  break;
                case 'rename':
                  _showRenameDialog(list['id'], list['title'], provider);
                  break;
                case 'delete':
                  _remove(list['id'], provider);
                  break;
              }
            },
          )
        ]),
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

  _showRenameDialog(String id, String title, ResultListProvider provider) {
    TextEditingController _controller = TextEditingController(text: title);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: TextField(
              decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).buttonColor))),
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
                  AppNavigate.pop(context);
                  var data =
                      await ListsApi.updateTitle(id, _controller.text.trim());
                  provider.update(data);
                },
              )
            ],
          );
        });
  }

  _showAddDialog() {
    ResultListProvider provider =
        Provider.of<ResultListProvider>(providerContext, listen: false);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController _controller = TextEditingController();
          return AlertDialog(
            content: TextField(
              controller: _controller,
              decoration: InputDecoration(
                  hintText: '列表名',
                  focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).buttonColor))),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('取消'),
                onPressed: () => AppNavigate.pop(context),
              ),
              FlatButton(
                child: Text('新建列表'),
                onPressed: () async {
                  AppNavigate.pop(context);
                  var newList = await ListsApi.add(_controller.text.trim());
                  provider.addToListWithAnimation(newList);
                },
              )
            ],
          );
        });
  }

  _remove(String id, ResultListProvider provider) async {
    await ListsApi.remove(id);
    provider.removeByIdWithAnimation(id);
  }
}
