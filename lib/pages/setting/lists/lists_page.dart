import 'package:fastodon/api/lists_api.dart';
import 'package:fastodon/constant/api.dart';
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/pages/setting/lists/lists_add.dart';
import 'package:fastodon/pages/setting/lists/lists_eidt.dart';
import 'package:fastodon/pages/timeline/lists_timeline.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/utils/dialog_util.dart';
import 'package:fastodon/widget/common/list_row.dart';
import 'package:fastodon/widget/common/normal_flat_button.dart';
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

  Widget _row(int idx, List data, ResultListProvider provider) {
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
    DialogUtils.showRoundedDialog(
        context: context, content: ListsEdit(listId, ""), radius: 3);
  }

  _showRenameDialog(String id, String title, ResultListProvider provider) {

    DialogUtils.showRoundedDialog(context: context,content: ListsRename(id: id,title: title,provider: provider,));

  }

  _showAddDialog() {
    ResultListProvider provider =
        Provider.of<ResultListProvider>(providerContext, listen: false);
    DialogUtils.showRoundedDialog(
        context: providerContext,
        content: ListsAdd(
          provider: provider,
        ));
  }

  _remove(String id, ResultListProvider provider) async {
    await ListsApi.remove(id);
    provider.removeByIdWithAnimation(id);
  }
}

class ListsRename extends StatefulWidget {
  final String id;
  final String title;
  final ResultListProvider provider;

  const ListsRename({Key key, this.id, this.title,this.provider}) : super(key: key);
  
  @override
  _ListsRenameState createState() => _ListsRenameState();
}

class _ListsRenameState extends State<ListsRename> {
  TextEditingController _controller;
  
  @override
  void initState() {
    _controller = TextEditingController(text: widget.title);
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12,12,12,5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                    BorderSide(color: Theme.of(context).buttonColor))),
            controller: _controller,
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              Spacer(),
              NormalCancelFlatButton(),
              NormalFlatButton(
                text: '重命名列表',
                onPressed: () async {
                  AppNavigate.pop(context);
                  var data =
                  await ListsApi.updateTitle(widget.id, _controller.text.trim());
                  widget.provider.update(data);
                },
              )
            ],
          )
        ],
      ),
    );
  }
}

